-- | Utilities used in modules from the @TestSupport@ folder.

{-# LANGUAGE GADTs      #-}
{-# LANGUAGE RankNTypes #-}
module Language.PlutusCore.Generators.Internal.Utils
    ( liftT
    , hoistSupply
    , choiceDef
    , forAllPretty
    , forAllPrettyT
    , forAllPrettyPlc
    , forAllPrettyPlcT
    ) where

import           Language.PlutusCore.Pretty (PrettyPlc, prettyPlcDefString)
import           PlutusPrelude              hiding (hoist)

import           Control.Monad.Morph
import           Control.Monad.Reader
import           Hedgehog                   hiding (Size, Var)
import qualified Hedgehog.Gen               as Gen
import           Hedgehog.Internal.Property (forAllWithT)

-- | @hoist lift@
liftT :: (MFunctor t, MonadTrans s, Monad m) => t m a -> t (s m) a
liftT = hoist lift

-- | Supply an environment to an inner 'ReaderT'.
hoistSupply :: (MFunctor t, Monad m) => r -> t (ReaderT r m) a -> t m a
hoistSupply r = hoist $ flip runReaderT r

-- | Same as 'Gen.choice', but with a default generator to be used
-- when the supplied list of generators is empty.
choiceDef :: Monad m => GenT m a -> [GenT m a] -> GenT m a
choiceDef a [] = a
choiceDef _ as = Gen.choice as

-- | Generate a value using the 'Pretty' class for getting its 'String' representation.
forAllPretty :: (Monad m, Pretty a) => Gen a -> PropertyT m a
forAllPretty = forAllWith prettyString

-- | Generate a value using the 'Pretty' class for getting its 'String' representation.
-- A supplied generator has access to the 'Monad' the whole property has access to.
forAllPrettyT :: (Monad m, Pretty a) => GenT m a -> PropertyT m a
forAllPrettyT = forAllWithT prettyString

-- | Generate a value using the 'PrettyPlc' constraint for getting its 'String' representation.
forAllPrettyPlc :: (Monad m, PrettyPlc a) => Gen a -> PropertyT m a
forAllPrettyPlc = forAllWith prettyPlcDefString

-- | Generate a value using the 'PrettyPlc' constraint for getting its 'String' representation.
-- A supplied generator has access to the 'Monad' the whole property has access to.
forAllPrettyPlcT :: (Monad m, PrettyPlc a) => GenT m a -> PropertyT m a
forAllPrettyPlcT = forAllWithT prettyPlcDefString
