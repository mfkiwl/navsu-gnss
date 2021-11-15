% Unit test script to test the functions navsu.svprn.mapSignalFreq,
% navsu.svprn.prn2sv, navsu.svprn.prn2x.
% Test 2 also tests navsu.svprn.prn2FreqChanGlonass

% some shared variables here
consts = navsu.thirdparty.initConstellation(1, 1, 1, 1, 0);
% julian date for the tests corresponding to 2018/03/01
jd = 2.458179318055556e+06;



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

% now test all three at once to validate the option of running multiple
% frequencies at once

allFreq = navsu.svprn.mapSignalFreq([1 2 5] .*ones(consts.(cString).numSat, 1), ...
                                    consts.(cString).PRN, ...
                                    consts.constInds(consts.(cString).indexes));
assert(all(allFreq == [1.57542, 1.2276, 1.17645]*1e+09, 'all'), ...
       ['Got ', cString, ' triple freq. case wrong!']);

%% Test 2: GLONASS frequencies
cString = 'GLONASS';

% just to G1
desiredAnswerG1 = 1.0e+09 * [1.6025625; 1.59975; 1.6048125; 1.605375; ...
                           1.6025625; 1.59975; 1.6048125; 1.605375; ...
                           1.600875; 1.5980625; 1.602; 1.6014375; ...
                           1.600875; 1.5980625; 1.602; 1.6014375; ...
                           1.60425; 1.6003125; 1.6036875; 1.603125; ...
                           1.60425; 1.6003125; 1.6036875; 1.603125];

gloG1 = navsu.svprn.mapSignalFreq(ones(consts.(cString).numSat, 1), ...
                                  consts.(cString).PRN, ...
                                  consts.constInds(consts.(cString).indexes), jd);
assert(all(gloG1 == desiredAnswerG1), ['Got ', cString, ' G1 wrong!']);

% try G1, G2, G2a at once plus an illegal one
desiredAnswerG12NaN3 = 1e6*[1602, 1246, NaN, 1248.06] ...
              + 1e6*[9/16, 7/16, 0, 0].*navsu.svprn.prn2FreqChanGlonass(consts.(cString).PRN, jd);
gloAll3 = navsu.svprn.mapSignalFreq([1 2 5 6] .* ones(consts.(cString).numSat, 1), ...
                                    consts.(cString).PRN, ...
                                    consts.constInds(consts.(cString).indexes), jd);
freqExists = isfinite(desiredAnswerG12NaN3);
assert(all(gloAll3(freqExists) == desiredAnswerG12NaN3(freqExists)), ...
    ['Got ', cString, ' triple freq. wrong!']);
assert(all(freqExists == isfinite(gloAll3), 'all'), ...
    ['Got ', cString, ' number of legal GLONASS signals wrong!']);


%% Test 3: GALILEO frequencies
cString = 'Galileo';

E1 = navsu.svprn.mapSignalFreq(ones(consts.(cString).numSat, 1), ...
                               consts.(cString).PRN, ...
                               consts.constInds(consts.(cString).indexes));
assert(all(E1 == 1.57542e+09), ['Got ', cString, ' E1 wrong!']);

E5 = navsu.svprn.mapSignalFreq(8*ones(consts.(cString).numSat, 1), ...
                               consts.(cString).PRN, ...
                               consts.constInds(consts.(cString).indexes));
assert(all(E5 == 1.191795e+09), ['Got ', cString, ' E5 wrong!']);

%% Test 4: Multi-frequency frequencies

L1G2EillegalE5a = navsu.svprn.mapSignalFreq( ...
    [[1 0] .* ones(consts.GPS.numSat, 1); ...
     [2 0] .* ones(consts.GLONASS.numSat, 1); ...
     [3 5] .* ones(consts.Galileo.numSat, 1)], ...
    [consts.GPS.PRN'; consts.GLONASS.PRN'; consts.Galileo.PRN'], ...
    consts.constInds([consts.GPS.indexes, consts.GLONASS.indexes, consts.Galileo.indexes])', ...
    jd);

expectedOutput = [[1575.42e+06 NaN].*ones(consts.GPS.numSat, 1); ...
                  [1246e+06 NaN]+7/16*1e+06*navsu.svprn.prn2FreqChanGlonass(consts.GLONASS.PRN, jd); ...
                  [NaN 1176.45e+06].*ones(consts.Galileo.numSat, 1)];

freqExists = isfinite(expectedOutput);
assert(all(L1G2EillegalE5a(freqExists) == expectedOutput(freqExists)), ...
       'Got multi constellation frequencies wrong!');
assert(all(freqExists == isfinite(L1G2EillegalE5a), 'all'), ...
       'Got number of legal multi-frequency signals wrong!');

%% Test 5: GPS SVN numbers
cString = 'GPS';

gpsSvns = [63 61 69 NaN 50 67 48 72 68 73 46 58 43 41 55 56 53 NaN 59 ...
           51 45 47 60 65 62 71 66 44 57 64 52 70]';
activeSats = isfinite(gpsSvns);

svn = navsu.svprn.prn2svn(consts.(cString).PRN', ...
                          jd, ...
                          consts.constInds(consts.(cString).indexes)');

% make sure we got the active ones right
assert(all(svn(activeSats) == gpsSvns(activeSats)), ...
       ['Failed to get ', cString, ' SVN numbers.']);

assert(all(isfinite(svn) == activeSats), ...
       ['Incorrect number of ', cString, ' PRNs active!']);

% now try with different input dimensions
svn = navsu.svprn.prn2svn(consts.(cString).PRN, ...
                          jd, ...
                          consts.constInds(consts.(cString).indexes)');
assert(all(svn(activeSats) == gpsSvns(activeSats)), ...
       'Failed prn2svn with column input.');

assert(all(isfinite(svn) == activeSats), ...
       'Failed prn2svn with column input.');

%% Test 6: Default to constellation GPS
svn = navsu.svprn.prn2svn(consts.GPS.PRN, jd);
gpsSvns = [63 61 69 NaN 50 67 48 72 68 73 46 58 43 41 55 56 53 NaN 59 ...
           51 45 47 60 65 62 71 66 44 57 64 52 70]';
activeSats = isfinite(gpsSvns);

assert(all(svn(activeSats) == gpsSvns(activeSats)), ...
       'prn2svn failed to default to GPS.');

assert(all(isfinite(svn) == activeSats), ...
       'prn2svn failed to default to GPS.');

%% Test 7: PRN 2 SVN 2 PRN
useConsts = {'GPS'; 'GLONASS'; 'Galileo'; 'BeiDou'};
prnCell = cellfun(@(x) consts.(x).PRN, useConsts, 'UniformOutput', false);
PRNs = horzcat(prnCell{:})';
constCell = cellfun(@(x) consts.(x).indexes, useConsts, 'UniformOutput', false);
constIds = consts.constInds(horzcat(constCell{:})');
prnAfter = navsu.svprn.svn2prn(navsu.svprn.prn2svn(PRNs, jd, constIds), ...
                               jd, ...
                               constIds);
prnExists = isfinite(prnAfter);
assert(all(prnAfter(prnExists) == PRNs(prnExists)), ...
       'Converting PRNs to SVNs and back failed.');
