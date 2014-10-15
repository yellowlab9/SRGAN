--------------------------------------------------------------------------------
-- Profiler main file
--------------------------------------------------------------------------------
-- Alfredo Canziani, Oct 14
--------------------------------------------------------------------------------

-- Requires --------------------------------------------------------------------
require 'nn'
require 'src/buildModel'
require 'src/profileNet'

-- Options ---------------------------------------------------------------------
torch.setdefaulttensortype('torch.FloatTensor')

--------------------------------------------------------------------------------
-- ILSVRC 2014 classification winner
-- VGG, single network D
name = 'VGG-D'
--------------------------------------------------------------------------------
-- Very Deep Convolutional Networks for Large-Scale Image Recognition
-- http://arxiv.org/abs/1409.1556
--------------------------------------------------------------------------------

-- Network parameters ----------------------------------------------------------
nFeatureMaps = {64,64,128,128,256,256,256,512,512,512,512,512,512}
filterSize   = { 3, 3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3}
convPadding  = { 1, 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1}
convStride   = { 1, 1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1}
poolSize     = { 1, 2,  1,  2,  1,  1,  2,  1,  1,  2,  1,  1,  2}
poolStride   = { 1, 2,  1,  2,  1,  1,  2,  1,  1,  2,  1,  1,  2}
hiddenUnits  = {4096, 4096, 1000}

-- Set colour input
mapSize         = {}
mapSize[0]      = {224, 224}
nFeatureMaps[0] = 3

-- Building model --------------------------------------------------------------
model = buildModel(name, nFeatureMaps, filterSize, convPadding, convStride,
   poolSize, poolStride, hiddenUnits, mapSize)

-- Profile net (forward only) --------------------------------------------------
operations = profileNet.ops(nFeatureMaps, filterSize, convPadding, convStride,
   poolSize, poolStride, hiddenUnits, mapSize)

iterations = 10; cuda = false
time = profileNet.time(name, model, nFeatureMaps, mapSize, iterations, cuda,
   operations)
