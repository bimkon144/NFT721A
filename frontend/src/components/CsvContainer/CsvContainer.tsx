import { SetStateAction, useEffect, useState } from 'react';
import CSVReader from '../CsvReader/CsvReader';
import { usePapaParse } from 'react-papaparse';
import { useMoralisWeb3Api } from "react-moralis";
import React from 'react';
import Select from 'react-select';
import { useWeb3React } from '@web3-react/core';
import { Provider } from '../../utils/provider';
import { BigNumber, ethers } from 'ethers';
import multisenderV1 from './MultiSenderV1.json'
import ERC20 from './ERC20.json'
import { observer } from 'mobx-react-lite';
import WebStore from "../../store/WebStore";


const CsvContainer: React.FC = observer(() => {
    const { readString } = usePapaParse();
    const context = useWeb3React<Provider>();
    const { library, active, account, chainId } = context;
    const multiSendContractAddress = "0xe776C27ebFe7D0Eb741aD3Ab113Bbcb5659396f5";

    const [loading, setLoading] = useState(true);
    const [selectedOption, setSelectedOption] = useState('');


    const Web3Api = useMoralisWeb3Api();

    const fetchTokenBalances = async () => {
        let netIdName,  nativeAssets, nativeAssetsAddress: any;
        const balance = await library!.getBalance(account!);
        switch (chainId) {
            case 56:
                netIdName = 'binance smart chain'
                nativeAssets = 'BNB'
                nativeAssetsAddress = '0xB8c77482e45F1F44dE1745F52C74426C631bDD52'
                console.log('This is binance mainnet', chainId)
                break;
            case 97:
                netIdName = 'binance testnet'
                nativeAssets = 'BNB'
                nativeAssetsAddress = '0x62b35Eb73edcb96227F666A878201b2cF915c2B5'
                console.log('This is binance test smart chain', chainId)
                break;
            default:
                netIdName = 'Unknown'
                console.log('This is an unknown network.', chainId)
        }
        const options: any = {
            chain: netIdName,
            address: account,
        };

        const balances = await Web3Api.account.getTokenBalances(options);
        let tokens = balances.map((contract) => {
            const { token_address, symbol, balance } = contract;
            return { label: `${symbol} - ${(+ethers.utils.formatUnits(balance)).toFixed(4)} - ${token_address}`, value: token_address }
        })

        tokens.unshift({
            value: nativeAssetsAddress,
            label: `${nativeAssets} - ${(+ethers.utils.formatUnits(balance)).toFixed(4)}`
        })
        WebStore.setTokensList(tokens);
    };


    const handleReadString = () => {
        readString(WebStore.textAreaPlaceholder, {
            worker: true,
            complete: (results: { data: any[]; }) => {
                const newArray = results.data.filter(n => n !='');
                WebStore.setData(newArray);

            },
        });
    };

    const multiSend = (event: { preventDefault: () => void; }): void => {
        event.preventDefault();

        if (!multiSendContractAddress) {
            window.alert('Undefined MultiSender contract');
            return;
        }
        async function handleMultiSend(multiSendContractAddress: string): Promise<void> {

            try {
                const signer = library!.getSigner();
                const multisSendContract = new ethers.Contract(multiSendContractAddress, multisenderV1.abi, signer);

                const tokenContract = new ethers.Contract(selectedOption, ERC20, signer);
                let result = WebStore.amounts.reduce(function (sum: ethers.BigNumber, elem) {
                    return sum.add(elem);
                }, BigNumber.from(0));
                if (selectedOption === WebStore.tokenList[0].value) {
                    console.log('fire');
                    await multisSendContract.multiSendNativeToken(WebStore.addresses, WebStore.amounts, { value: result });
                } else {
                    console.log('approve', (+ethers.utils.formatUnits(result)));
                    const approved = await tokenContract.approve(multiSendContractAddress, result)
                    await approved.wait();
                    const txdone = await multisSendContract.multiSendToken(selectedOption, WebStore.addresses, WebStore.amounts);
                    await txdone.wait();
                    fetchTokenBalances();
                }

            } catch (error: any) {
                window.alert(
                    'Error!' + (error && error.message ? `\n\n${error.message}` : '')
                );
            }
        }
        handleMultiSend(multiSendContractAddress);
    }


    const getValue = () => {
        return selectedOption ? WebStore.tokenList.find(c => c.value === selectedOption) : ''
    }

    const onChange = (newValue: any) => {
        setSelectedOption(newValue.value)
        console.log(newValue.value)
    }

    const handleChange = (event: any) => WebStore.textAreaPlaceholder = (event.target.value);

    useEffect((): void => {
        if (active) {
            setSelectedOption('');
            fetchTokenBalances();
            setLoading(false);
        } else {
            WebStore.setTokensList([{ label: '', value: '' }]);
            WebStore.textAreaPlaceholder = ('');
            setSelectedOption('');
            setLoading(true);
        }

    }, [active, chainId, account]);

    return (
        <div className='csv-container'>
            <div className='csv-container__item'>
                <Select
                    className='csv-container__select'
                    value={getValue()}
                    onChange={onChange}
                    isLoading={loading}
                    options={WebStore.tokenList}
                    isDisabled={WebStore.tokenList[0].label == '' ? true : false}
                    placeholder={WebStore.tokenList[0].label == '' ? "Loading your token addresses..." : "Your tokens are loaded"}
                />
            </div>
            <div className='csv-container__item'>
                <label className='csv-container__title' htmlFor='text-area'>Список адресов в формате csv </label>
                <textarea className='csv-container__text-area' onBlur={() => handleReadString()} id="text-area" name="csv-data" value={WebStore.textAreaPlaceholder} onChange={handleChange} />
            </div>
            <div className='csv-container__item'>
                <CSVReader />
            </div>
            <button className='csv-container__button' onClick={multiSend} type='button'>Далее</button>
        </div>
    );
})

export default CsvContainer;