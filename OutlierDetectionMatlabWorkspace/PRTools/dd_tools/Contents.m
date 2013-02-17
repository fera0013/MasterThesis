% Data Description Toolbox
% Version 1.9.1 4-May-2012
%
%Dataset construction
%--------------------
%isocset        true if dataset is one-class dataset
%gendatoc       generate a one-class dataset from two data matrices
%oc_set         change normal classif. problem to one-class problem
%target_class   extracts the target class from an one-class dataset
%gendatgrid     create a grid dataset around a 2D dataset
%gendatout      create outlier data in a hypersphere around the
%               target data
%gendatblockout create outlier data in a box around the target class
%gendatoutg     create outlier data normally distributed around the
%               target data
%gendatouts     create outlier data in the data PCA subspace in a
%               hypersphere around the target data
%gendatkriegel  artificial data according to Kriegel
%dd_crossval    cross-validation dataset creation
%dd_looxval     leave-one-out cross-validation dataset creation
%dd_label       put the classification labels in the same dataset
%
%Data preprocessing
%------------------
%dd_proxm       replacement for proxm.m
%kwhiten        rescale data to unit variance in kernel space
%gower          compute the Gower similarities
%
%One-class classifiers
%---------------------
%random_dd      description which randomly assigns labels
%stump_dd       threshold the first feature
%gauss_dd       data description using normal density
%rob_gauss_dd   robustified gaussian distribution
%mcd_gauss_dd   Minimum Covariance Determinant gaussian
%mog_dd         mixture of Gaussians data description
%mog_extend     extend a Mixture of Gaussians data description
%parzen_dd      Parzen density data description
%nparzen_dd     Naive Parzen density data description
%
%autoenc_dd     auto-encoder neural network data description
%kcenter_dd     k-center data description
%kmeans_dd      k-means data description
%pca_dd         principal component data description
%som_dd         Self-Organizing Map data description
%mst_dd         minimum spanning tree data description
%
%nndd           nearest neighbor based data description
%knndd          K-nearest neighbor data description
%ball_dd        L_p-ball data description
%lpball_dd      extended L_p-ball data description
%svdd           Support vector data description
%incsvdd        Incremental Support vector data description
%(incsvc         incremental support vector classifier)
%ksvdd          SVDD on general kernel matrices
%lpdd           linear programming data description
%mpm_dd         minimax probability machine data description
%lofdd          local outlier fraction data description
%lofrangedd     local outlier fraction over a range
%locidd         local correlation integral data description
%abof_dd        angle-based outlier fraction data description
%
%dkcenter_dd    distance k-center data description
%dnndd          distance nearest neighbor based data description
%dknndd         distance K-nearest neighbor data description
%dlpdd          distance-linear programming data description
%dlpsdd         distance-linear progr. similarity description
%
%isocc          true if classifier is one-class classifier
%
%AUC optimizers
%--------------
%rankboostc     Rank-boosting algorithm
%auclpm         AUC linear programming mapping
%
%Classifier postprocessing/optimization/combining.
%--------------------------------------
%consistent_occ optimize the hyperparameter using consistency
%optim_auc      optimize the hyperparameter by maximizing AUC
%dd_normc       normalize oc-classifier output
%multic         construct a multi-class classifier from OCC's
%ocmcc          one-class and multiclass classifier sequence
%
%Error computation.
%-----------------
%dd_error       false positive and negative fraction of classifier
%dd_confmat     confusion matrix
%dd_kappa       Cohen's kappa coefficient
%dd_f1          F1 score computation
%dd_eer         equal error rate
%dd_roc         computation of the Receiver-Operating Characterisic curve 
%dd_prc         computation of the Precision-Recall curve 
%dd_auc         error under the ROC curve
%dd_meanprec    mean precision of the Precision-Recall curve
%dd_costc       cost curve
%dd_delta_aic   AIC error for density estimators
%dd_fp          compute false positives for given false negative
%               fraction
%simpleroc      basic ROC curve computation
%dd_setfn       set the threshold for a false negative rate
%roc2prc        convert ROC to precision-recall curve
%
%Plot functions.
%--------------
%plotroc        plot an ROC curve or precision-recall curve
%plotcostc      plot the cost curve
%plotg          plot a 2D grid of function values
%plotw          plot a 2D real-valued output of classifier w
%askerplot      plot the FP and FN fraction wrt the thresholds
%plot_mst       plot the minimum spanning tree
%lociplot       plot a lociplot 
%
%Support functions.
%-----------------
%dd_version     current version of dd_tools, with upgrade possibility
%istarget       true if an object is target
%find_target    gives the indices of target and outlier objs from a dataset
%getoclab       returns numeric labels (+1/-1)
%dist2dens      map distance to posterior probabilities
%dd_threshold   give percentiles for a sample
%randsph        create outlier data uniformly in a unit hypersphere
%makegriddat    auxiliary function for constructing grid data
%relabel        relabel a dataset
%dd_kernel      general kernel definitions
%center         center the kernel matrix in kernel space
%gausspdf       multi-variate Gaussian prob.dens.function
%mahaldist      Mahalanobis distance
%sqeucldistm    square Euclidean distance
%mog_init       initialize a Mixture of Gaussians
%mog_P          probability density of Mixture of Gaussians
%mog_update     update a MoG using EM
%mogEMupdate    EM procedure to optimize Mixture of Gaussians
%mogEMextend    smartly extend a MoG and apply EM
%mykmeans       own implementation of the k-means clustering algorithm
%getfeattype    find the nominal and continuous features
%knn_optk       optimization of k for the knndd using leave-one-out
%volsphere      compute the volume of a hypersphere
%scale_range    compute a reasonable range of scales for a dataset
%nndist_range   compute the average nearest neighbor distance
%inc_setup      startup function incsvdd
%inc_add        add one object to an incsvdd
%inc_remove     remove one object from an incsvdd
%inc_store      store the structure obtained from inc_add to prtools mapping
%unrandomize    unrandomize objects for incsvc
%plotroc_update support function for plotroc
%roc_hull       convex hull over a ROC curve
%lpball_dist    lp-distance to a center
%lpball_vol     volume of a lpball
%lpdist         fast lp-distance between two datasets
%nndist         (average) nearest neighbor distance
%dd_message     printf with colors
%
%Examples
%--------
%dd_ex1         show performance of nndd and svdd
%dd_ex2         show the performances of a list of classifiers
%dd_ex3         shows the use of the svdd and ksvdd
%dd_ex4         optimizes a hyperparameter using consistent_occ
%dd_ex5         shows the construction of lpdd from dlpdd
%dd_ex6         shows the different Mixture of Gaussians classifiers
%dd_ex7         shows the combination of one-class classifiers
%dd_ex8         shows the interactive adjustment of the operating point
%dd_ex9         shows the use of dd_crossval
%dd_ex10        shows the use of the incremental SVDD
%dd_ex11        the construction of a multi-class classifier using OCCs
%dd_ex12        the precision-recall-curve and the ROC curve
%dd_ex13        kernelizing the AUCLPM
%dd_ex14        show the combination of a one-class and multi-class
%dd_ex15        show the parameter optimization mapping
%
% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands
