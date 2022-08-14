import { useMemo, useState } from "react";
import { JsonRpcProvider, Web3Provider } from "@ethersproject/providers";
import { Signer } from "ethers";
const parseProviderOrSigner = async providerOrSigner => {
  let signer = undefined;
  let provider;
  let providerNetwork;
  if (providerOrSigner && (providerOrSigner instanceof JsonRpcProvider || providerOrSigner instanceof Web3Provider)) {
    console.log("🔥 inside parseProvider");
    const accounts = await providerOrSigner.listAccounts();
    if (accounts && accounts.length > 0) {
      signer = providerOrSigner.getSigner();
    }
    provider = providerOrSigner;
    providerNetwork = await providerOrSigner.getNetwork();
  }
  if (!signer && providerOrSigner instanceof Signer) {
    signer = providerOrSigner;
    provider = signer.provider;
    providerNetwork = provider && (await provider.getNetwork());
  }
  return { signer, provider, providerNetwork };
};

const useUserProviderAndSigner = (injectedProviderOrSigner, localProvider, useBurnerWallet) => {
  const [signer, setSigner] = useState();
  const [provider, setProvider] = useState();
  const [providerNetwork, setProviderNetwork] = useState();
  useMemo(() => {
    if (injectedProviderOrSigner) {
      console.log("🦊 Using injected provider");
      console.log("🦊 Blah blah");
      void parseProviderOrSigner(injectedProviderOrSigner).then(result => {
        if (result != null) setSigner(result.signer);
      });
    } else if (!localProvider) {
      setSigner(undefined);
    } else {
      console.log("burner is off");
    }
  }, [injectedProviderOrSigner, localProvider]);
  useMemo(() => {
    if (signer) {
      const result = parseProviderOrSigner(signer);
      void result.then(r => {
        setProvider(r.provider);
        setProviderNetwork(r.providerNetwork);
      });
    }
  }, [signer]);
  return { signer, provider, providerNetwork };
};

export default useUserProviderAndSigner;
