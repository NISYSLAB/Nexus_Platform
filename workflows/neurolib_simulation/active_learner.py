from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, Flatten
from tensorflow.keras import initializers
from tensorflow.keras.regularizers import l2
from tensorflow.keras import optimizers
from tensorflow.keras import backend as K
import numpy as np
from sklearn.model_selection import StratifiedShuffleSplit
from modAL.models import ActiveLearner
from tensorflow.keras.wrappers.scikit_learn import KerasClassifier
import time
# https://github.com/tensorflow/tensorflow/issues/34201#issuecomment-690137283
# to make things work.....
from tensorflow.python.keras.backend import eager_learning_phase_scope  
## loading data
X = np.load('output_bold.npy')
y = np.load('output_label.npy')
num_classes = 2
num_init = 20  # amount of initial sample from each class
num_MCsamples = 100  # amount of repeats for mc sampling
num_epochs = 500   # amount of epochs to go through the training set
num_queries = 30     # amount of new queries to add to training set
num_batch = 1       # batch size
num_instances = 1   # amount of new sample each query
# 10-fold cross validation with 20% test
sss = StratifiedShuffleSplit(n_splits=10, test_size=0.2, random_state=0)

# initial samples
def init_sample(X_train,y_train):
    initial_idx = np.array([],dtype=np.int32)
    for i in range(num_classes):
        idx = np.random.choice(np.where(y_train==i)[0], size=num_init, replace=False)
        initial_idx = np.concatenate((initial_idx, idx))

    X_initial = X_train[initial_idx]
    y_initial = y_train[initial_idx]
    X_pool = np.delete(X_train, initial_idx, axis=0)
    y_pool = np.delete(y_train, initial_idx, axis=0)
    return X_initial,y_initial,X_pool,y_pool

# uniform
def uniform(learner, X, n_instances=1):
    query_idx = np.random.choice(range(len(X)), size=n_instances, replace=False)
    return query_idx, X[query_idx]

# maximum entropy
def max_entropy(learner, X, n_instances=1, T=100):
    if X.shape[0] > 2000:
        random_subset = np.random.choice(X.shape[0], 2000, replace=False)
    else:
        random_subset = np.array(range(X.shape[0]))
    MC_output = K.function([learner.estimator.model.layers[0].input],
                           [learner.estimator.model.layers[-1].output])
    with eager_learning_phase_scope(value=1):
        MC_samples = [MC_output([X[random_subset]])[0] for _ in range(T)]
    MC_samples = np.array(MC_samples)  # [#samples x batch size x #classes]
    expected_p = np.mean(MC_samples, axis=0)
    acquisition = - np.sum(expected_p * np.log(expected_p + 1e-10), axis=-1)  # [batch size]
    idx = (-acquisition).argsort()[:n_instances]
    query_idx = random_subset[idx]
    return query_idx, X[query_idx]

# BALD
def bald(learner, X, n_instances=1, T=100):
    if X.shape[0] > 2000:
        random_subset = np.random.choice(X.shape[0], 2000, replace=False)
    else:
        random_subset = np.array(range(X.shape[0]))
    MC_output = K.function([learner.estimator.model.layers[0].input],
                           [learner.estimator.model.layers[-1].output])
    with eager_learning_phase_scope(value=1):
        MC_samples = [MC_output([X[random_subset]])[0] for _ in range(T)]
    MC_samples = np.array(MC_samples)  # [#samples x batch size x #classes]
    expected_entropy = - np.mean(np.sum(MC_samples * np.log(MC_samples + 1e-10), axis=-1), axis=0)  # [batch size]
    expected_p = np.mean(MC_samples, axis=0)
    entropy_expected_p = - np.sum(expected_p * np.log(expected_p + 1e-10), axis=-1)  # [batch size]
    acquisition = entropy_expected_p - expected_entropy
    idx = (-acquisition).argsort()[:n_instances]
    query_idx = random_subset[idx]
    return query_idx, X[query_idx]

## building simple mlp model with dropout
def build_model():
    model = Sequential()
    init_scheme = initializers.HeNormal(time.time_ns())
    optimize_scheme = optimizers.Adam(learning_rate=0.001)
    model.add(Dense(128, input_dim=X.shape[1],activation='relu',kernel_initializer=init_scheme,bias_initializer="zeros"))
    model.add(Dropout(0.25))
    model.add(Dense(64,activation='relu',kernel_initializer=init_scheme,bias_initializer="zeros"))
    model.add(Dropout(0.25))
    model.add(Dense(32,activation='relu',kernel_initializer=init_scheme,bias_initializer="zeros"))
    model.add(Dropout(0.125))
    model.add(Dense(1,activation='sigmoid',kernel_initializer=init_scheme,bias_initializer="zeros"))
    model.compile(loss='binary_crossentropy', optimizer=optimize_scheme, metrics=['accuracy'])
    return model

def active_learning_procedure(query_strategy,
                              X_test,
                              y_test,
                              X_pool,
                              y_pool,
                              X_initial,
                              y_initial,
                              estimator,
                              epochs=num_epochs,
                              batch_size=num_batch,
                              n_queries=num_queries,
                              n_instances=num_instances,
                              verbose=0):
    learner = ActiveLearner(estimator=estimator,
                            X_training=X_initial,
                            y_training=y_initial,
                            query_strategy=query_strategy,
                            verbose=verbose
                           )
    print('Active learning using {strat} sampling strategy:'.format(strat=query_strategy.__name__))
    X_train = X_initial
    y_train = y_initial
    perf_hist = [learner.score(X_test, y_test, verbose=verbose)]
    train_hist = [learner.score(X_train,y_train,verbose=verbose)]
    for index in range(n_queries):
        query_idx, query_instance = learner.query(X_pool, n_instances)
        learner.teach(X_pool[query_idx], y_pool[query_idx], epochs=epochs, batch_size=batch_size, verbose=verbose)
        X_train = np.concatenate((X_train,X_pool[query_idx]))  # defaults to axis=0
        y_train = np.concatenate((y_train, y_pool[query_idx]))
        X_pool = np.delete(X_pool, query_idx, axis=0)
        y_pool = np.delete(y_pool, query_idx, axis=0)
        train_accuracy = learner.score(X_train,y_train,verbose=0)
        print('Train accuracy after query {n}: {acc:0.4f}'.format(n=index + 1, acc=train_accuracy))
        train_hist.append(train_accuracy)

        model_accuracy = learner.score(X_test, y_test, verbose=0)
        print('Validation accuracy after query {n}: {acc:0.4f}'.format(n=index + 1, acc=model_accuracy))
        perf_hist.append(model_accuracy)
    return train_hist, perf_hist


for i, (train_index, test_index) in enumerate(sss.split(X, y)):
    print(f"Fold {i}:")
    print(f"  Train: index={train_index}")
    print(f"  Test:  index={test_index}")
    print(f"  Train: label={y[train_index]}")
    print(f"  Test: label={y[test_index]}")
    X_train = X[train_index,:]
    y_train = y[train_index]
    X_test = X[test_index,:]
    y_test = y[test_index]

    # train on entire training set as maximum 
    model = build_model()
    # 300 epochs seem good for num_subject = 10
    history = model.fit(X_train, y_train, epochs=5000, validation_data=(X_test, y_test),verbose=1)
    np.save("entire_set_fold{0}_acc.npy".format(i),history.history['accuracy'])
    np.save("entire_set_fold{0}_val_acc.npy".format(i),history.history['val_accuracy'])
    del history
    del model

    ## random sampling
    X_initial,y_initial,X_pool,y_pool = init_sample(X_train,y_train)
    estimator = KerasClassifier(build_model)
    uniform_train_hist, uniform_perf_hist = active_learning_procedure(uniform,
                                                X_test,
                                                y_test,
                                                X_pool,
                                                y_pool,
                                                X_initial,
                                                y_initial,
                                                estimator,)
    np.save("keras_uniform{0}.npy".format(i), uniform_perf_hist)
    np.save("keras_uniform_train{0}.npy".format(i),uniform_train_hist)
    del estimator
    del uniform_perf_hist
    del uniform_train_hist

    ## maximum entropy
    X_initial,y_initial,X_pool,y_pool = init_sample(X_train,y_train)
    estimator = KerasClassifier(build_model)
    entropy_train_hist, entropy_perf_hist = active_learning_procedure(max_entropy,
                                                X_test,
                                                y_test,
                                                X_pool,
                                                y_pool,
                                                X_initial,
                                                y_initial,
                                                estimator,)
    np.save("keras_max_entropy{0}.npy".format(i), entropy_perf_hist)
    np.save("keras_max_entropy_train{0}.npy".format(i),entropy_train_hist)
    del estimator
    del entropy_perf_hist
    del entropy_train_hist

    ## bald
    X_initial,y_initial,X_pool,y_pool = init_sample(X_train,y_train)
    estimator = KerasClassifier(build_model)
    bald_train_hist, bald_perf_hist = active_learning_procedure(bald,
                                            X_test,
                                            y_test,
                                            X_pool,
                                            y_pool,
                                            X_initial,
                                            y_initial,
                                            estimator,)
    np.save("keras_bald{0}.npy".format(i), bald_perf_hist)
    np.save("keras_bald_train{0}.npy".format(i),bald_train_hist)
    del estimator
    del bald_perf_hist
    del bald_train_hist

    del X_pool,y_pool,X_initial,y_initial

