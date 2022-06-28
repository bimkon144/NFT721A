import { ethers } from "ethers";
import { makeAutoObservable } from "mobx";

// Standard interface and functions
interface Todo {
  id: number;
  text: string;
  done: boolean;
}




class WebStore {

  addresses: string[] = [];
  amounts: ethers.BigNumber[] = [];
  textAreaPlaceholder: string = '';
  tokenList = [{ label: '', value: '' }];

  constructor() {
    makeAutoObservable(this);
  }

  setData(data: string[][]) {
    const addresses: string[] = [];
    const values: ethers.BigNumber[] = [];
    data.forEach((element, index) => {
      addresses.push(element[0]);
    });
    data.forEach((element, index) => {
      values.push(ethers.utils.parseEther(element[1]));
    });
    this.addresses = addresses;
    this.amounts = values;
  }

  setTextAreaPlaceholder(data: string[][]) {
    this.textAreaPlaceholder = data.join('\r\n')
  }

  setTokensList(tokens: { label: string, value: string }[]) {
    this.tokenList = tokens;
  }

  // load(url: string) {
  //   fetch(url)
  //     .then((resp) => resp.json())
  //     .then((tds: Todo[]) => (store.todos = tds));
  // }
}


export default new WebStore();