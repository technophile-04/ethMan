/* eslint-disable react/jsx-pascal-case */
import { Button, Card, List, Skeleton, Space } from "antd";
import { useContractReader } from "eth-hooks";
import React, { useEffect, useState } from "react";
import { Address, AddressInput } from "../components";

/**
 * web3 props can be passed from '../App.jsx' into your local view component for use
 * @param {*} yourLocalBalance balance on current network
 * @param {*} readContracts contracts from current chain already pre-loaded using ethers contract module. More here https://docs.ethers.io/v5/api/contract/contract/
 * @returns react component
 **/
function Home({
  userSigner,
  readContracts,
  writeContracts,
  tx,
  loadWeb3Modal,
  blockExplorer,
  mainnetProvider,
  address,
}) {
  console.log("readContracts", readContracts);
  console.log("Address in home", address);
  const balanceContract = useContractReader(readContracts, "ETHMan", "balanceOf", [address]);
  const priceContract = useContractReader(readContracts, "ETHMan", "PRICE");

  const [balance, setBalance] = useState();
  const [price, setPrice] = useState();

  const [transferToAddresses, setTransferToAddresses] = useState({});

  useEffect(() => {
    if (balanceContract) {
      console.log("Balance", balanceContract);
      setBalance(balanceContract);
    }
  }, [balanceContract]);

  useEffect(() => {
    if (priceContract) {
      setPrice(priceContract);
    }
  }, [priceContract]);

  const [ethMan, setEthMan] = useState();
  const [loading, setLoading] = useState(false);

  console.log("Home: " + address + ", Balance: " + balance);

  useEffect(() => {
    const updateYourCollectibles = async () => {
      const collectibleUpdate = [];
      setLoading(true);
      for (let tokenIndex = 0; tokenIndex < balance; ++tokenIndex) {
        try {
          console.log("Getting token index " + tokenIndex);
          const tokenId = await readContracts.ETHMan.tokenOfOwnerByIndex(address, tokenIndex);
          console.log("tokenId: " + tokenId);
          const tokenURI = await readContracts.ETHMan.tokenURI(tokenId);
          const jsonManifestString = Buffer.from(tokenURI.substring(29), "base64").toString();
          console.log("jsonManifestString: " + jsonManifestString);

          try {
            const jsonManifest = JSON.parse(jsonManifestString);
            console.log("jsonManifest: " + jsonManifest);
            collectibleUpdate.push({ id: tokenId, uri: tokenURI, owner: address, ...jsonManifest });
          } catch (err) {
            console.log(err);
          }
        } catch (err) {
          setLoading(false);
          console.log(err);
        }
      }
      setEthMan(collectibleUpdate.reverse());
      setLoading(false);
    };
    if (address && balance) updateYourCollectibles();
  }, [address, balance, readContracts]);

  return (
    <div>
      <div style={{ maxWidth: 820, margin: "auto", marginTop: 32, paddingBottom: 32 }}>
        {userSigner ? (
          <Button
            type={"primary"}
            onClick={() => {
              tx(writeContracts.ETHMan.mintItem({ value: price }));
            }}
          >
            MINT
          </Button>
        ) : (
          <Button type={"primary"} onClick={loadWeb3Modal}>
            CONNECT WALLET
          </Button>
        )}
      </div>

      <div style={{ width: 820, margin: "auto", paddingBottom: 256 }}>
        <List
          bordered
          dataSource={ethMan}
          renderItem={item => {
            const id = item.id.toNumber();

            console.log("IMAGE", item.image);

            return (
              <List.Item key={id + "_" + item.uri + "_" + item.owner}>
                <Skeleton loading={loading} active>
                  <Card
                    title={
                      <div>
                        <span style={{ fontSize: 18, marginRight: 8 }}>{item.name}</span>
                      </div>
                    }
                  >
                    <a
                      href={
                        "https://opensea.io/assets/" +
                        (readContracts && readContracts.ETHMan && readContracts.ETHMan.address) +
                        "/" +
                        item.id
                      }
                      target="_blank"
                      rel="noreferrer"
                    >
                      <img src={item.image} alt="ETH Man" />
                    </a>
                    <div>{item.description}</div>
                  </Card>

                  <Space direction="vertical" size={"middle"} style={{ marginLeft: "1rem" }}>
                    <div>
                      Owner:{" "}
                      <Address
                        address={item.owner}
                        ensProvider={mainnetProvider}
                        blockExplorer={blockExplorer}
                        fontSize={16}
                      />
                    </div>

                    <AddressInput
                      ensProvider={mainnetProvider}
                      placeholder="transfer to address"
                      value={transferToAddresses[id]}
                      onChange={newValue => {
                        const update = {};
                        update[id] = newValue;
                        setTransferToAddresses({ ...transferToAddresses, ...update });
                      }}
                    />
                    <Button
                      onClick={() => {
                        console.log("writeContracts", writeContracts);
                        tx(writeContracts.ETHMan.transferFrom(address, transferToAddresses[id], id));
                      }}
                    >
                      Transfer
                    </Button>
                  </Space>
                </Skeleton>
              </List.Item>
            );
          }}
        />
      </div>
    </div>
  );
}

export default Home;
