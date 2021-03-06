module Language.PlutusCore.Generators.Test
    ( propEvaluate
    ) where

import           Language.PlutusCore
import           Language.PlutusCore.Constant
import           Language.PlutusCore.Evaluation.Result
import           Language.PlutusCore.Generators
-- import           Language.PlutusCore.Pretty
import           PlutusPrelude                         (PrettyConfigIgnore (..))

import           Control.Monad.Except
import           Control.Monad.Morph
import           Data.Foldable
import           Hedgehog                              hiding (Size, Var, eval)

-- | A property-based testing procedure for evaluators.
-- Checks whether a term generated along with the value it's supposed to compute to
-- indeed computes to that value according to the provided evaluate.
propEvaluate
    :: (Term TyName Name () -> EvaluationResult)       -- ^ An evaluator.
    -> GenT Quote (TermOf (TypedBuiltinValue Size a))  -- ^ A term/value generator.
    -> Property
propEvaluate eval genTermOfTbv = property . hoist (return . runQuote) $ do
    TermOf term (PrettyConfigIgnore tbv) <-
        forAllPrettyPlcT $ fmap PrettyConfigIgnore <$> genTermOfTbv
    -- TODO: return type checking.
    -- case runExcept . runQuoteT $ annotateTerm term >>= typecheckTerm (TypeCheckCfg 1000 True) of
    --     Left err -> fail $ prettyPlcCondensedErrorClassicString err
    --     Right _  -> return ()
    resExpected <- lift $ unsafeMakeBuiltin tbv
    for_ (evaluationResultToMaybe $ eval term) $ \resActual ->
        resActual === resExpected
