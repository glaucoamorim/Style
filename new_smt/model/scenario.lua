---------------------------------------------------------------------
-- Enumeration of possible types of model to be validated.
-- 
-- @module model.scenario
-- @author Joel dos Santos <joel@dossantos.cc>

require('lib.util')


--- Enumeration of possible types of model to be validated. The possible
-- types are: `T` for a purely temporal model, `S` for a purely spatial
-- model, and `ST` for a spatio-temporal model.
SCENARIO = enum{"T", "S", "ST"}