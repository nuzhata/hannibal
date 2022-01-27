// import { ChainId } from '@pancakeswap-libs/sdk';
import { ChainId } from '@spookyswap/sdk';
import { Configuration } from './tomb-finance/config';
import { BankInfo } from './tomb-finance';

const configurations: { [env: string]: Configuration } = {
  development: {
    //NUZHAT:
    // chainId: 3,
    // networkName: 'Ropsten Test Network',
    // ftmscanUrl: 'https://ropsten.etherscan.io',
    // defaultProvider: 'https://ropsten.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161',
    chainId: ChainId.FTMTESTNET,
    networkName: 'Fantom Opera Testnet',
    ftmscanUrl: 'https://testnet.ftmscan.com',
    defaultProvider: 'https://rpc.testnet.fantom.network/',
    deployments: require('./tomb-finance/deployments/deployments.testing.json'),
    externalTokens: {
      WFTM: ['0xf1277d1ed8ad466beddf92ef448a132661956621', 18],
      FUSDT: ['0xb7f24e6e708eabfaa9e64b40ee21a5adbffb51d6', 6],
      BOO: ['0x14f0C98e6763a5E13be5CE014d36c2b69cD94a1e', 18],
      ZOO: ['0x2317610e609674e53D9039aaB85D8cAd8485A7c5', 0],
      SHIBA: ['0x39523112753956d19A3d6a30E758bd9FF7a8F3C0', 9],
      'USDT-FTM-LP': ['0xE7e3461C2C03c18301F66Abc9dA1F385f45047bA', 18],
      'HAN-FTM-LP': ['0x13Fe199F19c8F719652985488F150762A5E9c3A8', 18],
      'TSHARE-FTM-LP': ['0x20bc90bB41228cb9ab412036F80CE4Ef0cAf1BD5', 18],
    },
    baseLaunchDate: new Date('2021-06-02 13:00:00Z'),
    bondLaunchesAt: new Date('2020-12-03T15:00:00Z'),
    masonryLaunchesAt: new Date('2020-12-11T00:00:00Z'),
    refreshInterval: 10000,
  },
  production: {
    chainId: ChainId.MAINNET,
    networkName: 'Fantom Opera Mainnet',
    ftmscanUrl: 'https://ftmscan.com',
    defaultProvider: 'https://rpc.ftm.tools/',
    deployments: require('./tomb-finance/deployments/deployments.mainnet.json'),
    externalTokens: {
      WFTM: ['0x21be370d5312f44cb42ce377bc9b8a0cef1a4c83', 18],
      FUSDT: ['0x04068DA6C83AFCFA0e13ba15A6696662335D5B75', 6], // This is actually usdc on mainnet not fusdt
      BOO: ['0x841FAD6EAe12c286d1Fd18d1d525DFfA75C7EFFE', 18],
      ZOO: ['0x09e145a1d53c0045f41aeef25d8ff982ae74dd56', 0],
      SHIBA: ['0x9ba3e4f84a34df4e08c112e1a0ff148b81655615', 9],
      'USDT-FTM-LP': ['0x2b4C76d0dc16BE1C31D4C1DC53bF9B45987Fc75c', 18],
      'TOMB-FTM-LP': ['0x2A651563C9d3Af67aE0388a5c8F89b867038089e', 18],
      'TSHARE-FTM-LP': ['0x4733bc45eF91cF7CcEcaeeDb794727075fB209F2', 18],
    },
    baseLaunchDate: new Date('2021-06-02 13:00:00Z'),
    bondLaunchesAt: new Date('2020-12-03T15:00:00Z'),
    masonryLaunchesAt: new Date('2020-12-11T00:00:00Z'),
    refreshInterval: 10000,
  },
};

export const bankDefinitions: { [contractName: string]: BankInfo } = {
  /*
  Explanation:
  name: description of the card
  poolId: the poolId assigned in the contract
  sectionInUI: way to distinguish in which of the 3 pool groups it should be listed
        - 0 = Single asset stake pools
        - 1 = LP asset staking rewarding TOMB
        - 2 = LP asset staking rewarding TSHARE
  contract: the contract name which will be loaded from the deployment.environmnet.json
  depositTokenName : the name of the token to be deposited
  earnTokenName: the rewarded token
  finished: will disable the pool on the UI if set to true
  sort: the order of the pool
  */
  HanFtmRewardPool: {
    name: 'Earn HAN by FTM',
    poolId: 0,
    sectionInUI: 0,
    contract: 'HanFtmRewardPool',
    depositTokenName: ' ',
    earnTokenName: 'HAN',
    finished: false,
    sort: 1,
    closedForStaking: true,
  },
  HanBooRewardPool: {
    name: 'Earn HAN by BOO',
    poolId: 1,
    sectionInUI: 0,
    contract: 'HanBooGenesisRewardPool',
    depositTokenName: 'BOO',
    earnTokenName: 'HAN',
    finished: false,
    sort: 2,
    closedForStaking: true,
  },
  HanShibaRewardPool: {
    name: 'Earn HAN by SHIBA',
    poolId: 2,
    sectionInUI: 0,
    contract: 'HanShibaGenesisRewardPool',
    depositTokenName: 'SHIBA',
    earnTokenName: 'HAN',
    finished: false,
    sort: 3,
    closedForStaking: true,
  },
  HanZooRewardPool: {
    name: 'Earn HAN by ZOO',
    poolId: 3,
    sectionInUI: 0,
    contract: 'HanZooGenesisRewardPool',
    depositTokenName: 'ZOO',
    earnTokenName: 'HAN',
    finished: false,
    sort: 4,
    closedForStaking: true,
  },
  HanFtmLPHanRewardPool: {
    name: 'Earn HAN by HAN-FTM LP',
    poolId: 0,
    sectionInUI: 1,
    contract: 'HanFtmLpHanRewardPool',
    depositTokenName: 'HAN-FTM-LP',
    earnTokenName: 'HAN',
    finished: false,
    sort: 5,
    closedForStaking: true,
  },
  HanFtmLPHanRewardPoolOld: {
    name: 'Earn HAN by HAN-FTM LP',
    poolId: 0,
    sectionInUI: 1,
    contract: 'HanFtmLpHanRewardPoolOld',
    depositTokenName: 'HAN-FTM-LP',
    earnTokenName: 'HAN',
    finished: true,
    sort: 9,
    closedForStaking: true,
  },
  HanFtmLPHaShareRewardPool: {
    name: 'Earn HaSHARE by HAN-FTM LP',
    poolId: 0,
    sectionInUI: 2,
    contract: 'HanFtmLPHaShareRewardPool',
    depositTokenName: 'HAN-FTM-LP',
    earnTokenName: 'HASHARE',
    finished: false,
    sort: 6,
    closedForStaking: false,
  },
  HashareFtmLPHaShareRewardPool: {
    name: 'Earn HaSHARE by HaSHARE-FTM LP',
    poolId: 1,
    sectionInUI: 2,
    contract: 'HaShareFtmLPHaShareRewardPool',
    depositTokenName: 'TSHARE-FTM-LP',
    earnTokenName: 'HASHARE',
    finished: false,
    sort: 7,
    closedForStaking: false,
  },
};

//NZ:
// export default configurations[process.env.NODE_ENV || 'development'];
export default configurations['development'];
