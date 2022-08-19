<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/bimkon144/NFT721A">
    <img src="https://img.freepik.com/premium-vector/non-fungible-nft-token-non-fungible-token-logo-design-background-blue-and-purple-neon-light_268461-40.jpg" alt="Logo" width="200" height="200">
  </a>

<h3 align="center">NFT721A</h3>

  <p align="center">
    sample NFT721
    <br />
    <a href="https://github.com/bimkon144/NFT721A"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/bimkon144/NFT721A">View Demo</a>
    ·
    <a href="https://github.com/bimkon144/NFT721A/issues">Report Bug</a>
    ·
    <a href="https://github.com/bimkon144/NFT721A/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

This is a sample of NFT-721A project to deploy to testnet. 

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

* [![Hardhat][Hardhat]][Hardhat-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started



### Prerequisites

* npm
  ```sh
  npm install npm@latest -g
  ```
* install [metamask](https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn) extension

* add Goerli testnet to metamask networks
* claim your test assets from goerli [faucet](https://goerlifaucet.com/)

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/bimkon144/NFT721A.git
   ```
2. Install NPM packages
   ```sh
   npm install
   ```
3. Enter your wallet address in `contractAddresses.js`
   ```js
   walletAddress: 'ENTER_YOUR_ADDRESS';
   ```
   
4. create .env in root derictory with keys like in .env.example


5. go to [alchemy](https://auth.alchemyapi.io/?redirectUrl=https%3A%2F%2Fdashboard.alchemyapi.io%2Fsignup%2F) create goerli network app and get api key.
  Enter the key in .env
     ```js
   GOERLI_RPC_URL="ENTER_YOUR_KEY";
   ```
6. [get](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-export-an-account-s-private-key) your wallet private key from metamask.
  Enter the key in .env
     ```js
   WALLET_KEY="ENTER_YOUR_PRIVATE_KEY";
   ```
6. [get](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-export-an-account-s-private-key) your wallet private key from metamask.
  Enter the key in .env
     ```js
   WALLET_KEY="ENTER_YOUR_PRIVATE_KEY";
   ```
 8. run deploy script  - `npx hardhat run tasks/deploy.ts --network goerli`
 
 9. Congratulations! Now you got your deployed and verified contract. You can check it on etherscan.


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Alexei kutsenko - aleksei.kutsenko@metalamp.io.com

Project Link: [https://github.com/bimkon144/NFT721A](https://github.com/bimkon144/NFT721A)

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/bimkon144/NFT721A.svg?style=for-the-badge
[contributors-url]: https://github.com/bimkon144/NFT721A/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/bimkon144/NFT721A.svg?style=for-the-badge
[forks-url]: https://github.com/bimkon144/NFT721A/network/members
[stars-shield]: https://img.shields.io/github/stars/bimkon144/NFT721A.svg?style=for-the-badge
[stars-url]: https://github.com/bimkon144/NFT721A/stargazers
[issues-shield]: https://img.shields.io/github/issues/bimkon144/NFT721A.svg?style=for-the-badge
[issues-url]: https://github.com/bimkon144/NFT721A/issues
[license-shield]: https://img.shields.io/github/license/bimkon144/NFT721A.svg?style=for-the-badge
[license-url]: https://github.com/bimkon144/NFT721A/blob/master/LICENSE.txt
[product-screenshot]: images/screenshot.png
[Hardhat]: https://img.shields.io/badge/hardhat-2.8.0-yellow
[Hardhat-url]: https://hardhat.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com 
