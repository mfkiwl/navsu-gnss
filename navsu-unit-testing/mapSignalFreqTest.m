% some shared variables here
consts = navsu.thirdparty.initConstellation(1, 1, 1, 1, 0);


%% Test 1: GPS frequencies
cString = 'GPS';

L1 = navsu.svprn.mapSignalFreq(ones(consts.(cString).numSat, 1), ...
                               consts.(cString).PRN, ...
                               consts.constInds(consts.(cString).indexes));
assert(all(L1 == 1.57542e+09), ['Got ', cString, ' L1 wrong!']);

L2 = navsu.svprn.mapSignalFreq(2*ones(consts.(cString).numSat, 1), ...
                               consts.(cString).PRN, ...
                               consts.constInds(consts.(cString).indexes));
assert(all(L2 == 1.2276e+09), ['Got ', cString, ' L2 wrong!']);

L5 = navsu.svprn.mapSignalFreq(5*ones(consts.(cString).numSat, 1), ...
                               consts.(cString).PRN, ...
                               consts.constInds(consts.(cString).indexes));
assert(all(L5 == 1.17645e+09), ['Got ', cString, ' L5 wrong!']);

%% Test 2: GLONASS frequencies
cString = 'GLONASS';

jd = 2.458179318055556e+06; % julian date

desiredAnswer = 1.0e+09 * [1.6025625; 1.59975; 1.6048125; 1.605375; ...
                           1.6025625; 1.59975; 1.6048125; 1.605375; ...
                           1.600875; 1.5980625; 1.602; 1.6014375; ...
                           1.600875; 1.5980625; 1.602; 1.6014375; ...
                           1.60425; 1.6003125; 1.6036875; 1.603125; ...
                           1.60425; 1.6003125; 1.6036875; 1.603125];

gloL1 = navsu.svprn.mapSignalFreq(ones(consts.(cString).numSat, 1), ...
                                  consts.(cString).PRN, ...
                                  consts.constInds(consts.(cString).indexes), jd);
assert(all(gloL1 == desiredAnswer), ['Got ', cString, ' L1 wrong!']);

%% Test 3: GALILEO frequencies
cString = 'Galileo';

L1 = navsu.svprn.mapSignalFreq(ones(consts.(cString).numSat, 1), ...
                               consts.(cString).PRN, ...
                               consts.constInds(consts.(cString).indexes));
assert(all(L1 == 1.57542e+09), ['Got ', cString, ' E1 wrong!']);

% L2 = navsu.svprn.mapSignalFreq(2*ones(32, 1), consts.(cString).PRN, ...
%     consts.constInds(consts.(cString).indexes));
% assert(all(L2 == 1.2276e+09), ['Got ', cString, ' L2 wrong!']);

L5 = navsu.svprn.mapSignalFreq(8*ones(consts.(cString).numSat, 1), ...
                               consts.(cString).PRN, ...
                               consts.constInds(consts.(cString).indexes));
assert(all(L5 == 1.191795e+09), ['Got ', cString, ' E5 wrong!']);


