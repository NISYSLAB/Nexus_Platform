from sklearn.model_selection import BaseCrossValidator
from sklearn.model_selection._split import _BaseKFold
from sklearn.model_selection import GroupKFold
import numpy as np

# custom cross validation splitter to perform stratified group kfold
# Used for situations where sequential parts of the data has the same label
# while all parts are split into groups
# testing on cluster shows this does not work with scikit-learn 0.23.1 but it works locally with 1.3.0
# I updated sklearn on cluster venv....


class CustomGroupStratifiedKFold(_BaseKFold, BaseCrossValidator):
    def __init__(self, n_splits=5,n_meta=2):
        super().__init__(n_splits, shuffle=False, random_state=None)
        self.n_splits = n_splits
        self.n_meta = n_meta

    def split(self, X, y=None, groups=None):
        group_kfolds = [GroupKFold(n_splits=self.n_splits) for i in range(self.n_meta)]
        splits = [None]*self.n_meta
        for j in range(self.n_splits):
            train_idx = []
            test_idx = []
            for i in range(self.n_meta):
                XX = X[range(X.shape[0]//self.n_meta * i,X.shape[0]//self.n_meta * (i+1)),:]
                yy = y[range(y.shape[0]//self.n_meta * i,y.shape[0]//self.n_meta * (i+1))]
                gg = groups[range(groups.shape[0]//self.n_meta * i,groups.shape[0]//self.n_meta * (i+1))]
                if j==0:
                    splits[i] = list(group_kfolds[i].split(XX, yy, groups=gg))
                train_idx_g = splits[i][j][0] + X.shape[0]//self.n_meta * i
                test_idx_g = splits[i][j][1] + X.shape[0]//self.n_meta * i
                train_idx.extend(train_idx_g)
                test_idx.extend(test_idx_g)
            # yeaaap everything works now...
            # print(train_idx)
            # print(test_idx)
            yield train_idx, test_idx

    def get_n_splits(self, X=None, y=None, groups=None):
        return self.n_splits