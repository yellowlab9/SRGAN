--------------------------------------------------------------------------------
-- Build model, given its parameters
-- No <dropout> since only forward model is considered
--------------------------------------------------------------------------------
-- Alfredo Canziani, Oct 14
--------------------------------------------------------------------------------

-- Requires --------------------------------------------------------------------
require 'sys'

-- Local definitions -----------------------------------------------------------
local pf = function(...) print(string.format(...)) end
local r = sys.COLORS.red
local n = sys.COLORS.none

-- Public function -------------------------------------------------------------
function buildModel(name, nFeatureMaps, filterSize, convPadding, convStride,
   poolSize, poolStride, hiddenUnits, mapSize)
   pf('Building %s model...', r..name..n)
   collectgarbage()

   -- Computing useful figures -------------------------------------------------
   -- Feature maps size and neurons number
   local neurons = {}
   neurons.real = {}
   neurons.pool = {}
   local f = math.floor
   for i = 1, #nFeatureMaps do
      mapSize[i] = {}
      mapSize[i][1] = f((mapSize[i-1][2] + 2 * convPadding[i] - filterSize[i]) /
         convStride[i]) + 1
      mapSize[i][2] = f((mapSize[i][1] - poolSize[i]) / poolStride[i]) + 1
      neurons.real[i] = mapSize[i][1]^2 * nFeatureMaps[i]
      neurons.pool[i] = mapSize[i][2]^2 * nFeatureMaps[i]
   end
   for _, h in ipairs(hiddenUnits) do
      table.insert(neurons.real, h)
      table.insert(neurons.pool, h)
   end

   -- Model definition ---------------------------------------------------------
   -- Convolution container
   local convBlock = nn.Sequential()

   for i, nbMap in ipairs(nFeatureMaps) do

      -- Convolution
      convBlock:add(
         nn.SpatialConvolutionMM(
            nFeatureMaps[i-1], nbMap,
            filterSize[i], filterSize[i],
            convStride[i], convStride[i],
            convPadding[i])
         )

      -- Non linearity
      convBlock:add(nn.ReLU())

      -- Pooling
      if poolSize[i] > 1 then
         convBlock:add(
            nn.SpatialMaxPooling(
               poolSize[i], poolSize[i],
               poolStride[i], poolStride[i])
            )
      end

   end

   -- MLP
   -- Defining classifier
   local classifier = nn.Sequential()

   classifier:add(nn.Reshape(neurons.pool[#nFeatureMaps]))

   for i = 1, #hiddenUnits do
      classifier:add(
         nn.Linear(neurons.pool[#nFeatureMaps+i-1],neurons.pool[#nFeatureMaps+i])
         )
      if i < #hiddenUnits then
         classifier:add(nn.ReLU())
      else
         classifier:add(nn.LogSoftMax())
      end
   end

   -- Full model
   -- Defining container
   local model = nn.Sequential()
   model:add(convBlock)
   model:add(classifier)
   model.neurons = neurons

   pf('   Total number of neurons: %d', torch.Tensor(neurons.real):sum())
   pf('   Total number of trainable parameters: %d',
      model:getParameters():size(1))

   return model

end
