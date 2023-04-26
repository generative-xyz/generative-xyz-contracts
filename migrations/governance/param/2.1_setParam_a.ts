import * as dotenv from 'dotenv';

import {ParamControl} from "./paramControl";
import {ethers} from "ethers";

(async () => {
    try {
        if (process.env.NETWORK != "tc_mainnet") {
            console.log("wrong network");
            return;
        }
        const args = process.argv.slice(2)
        const contract = args[0];

        const data = [
            {
                "walletAddress": "0x3076152f82d20FB00dBc75CBa289E31317370226"
            },
            {
                "walletAddress": "0x924e7B43b8C7E15df6d59e600a1f6c441735ba9e"
            },
            {
                "walletAddress": "0x1028A293613ef05a052494cDb0Db0EAF17564892"
            },
            {
                "walletAddress": "0xeEB716Ad3653EEC01F94840c22aBe35e27f53523"
            },
            {
                "walletAddress": "0xdC9D4710C6917e6254B82c0f4430904E625A937e"
            },
            {
                "walletAddress": "0x19666537257E311119955c8EfbEC6a8Ac188fD92"
            },
            {
                "walletAddress": "0xEed5a29524CbB5C87414c08c28ce6B51c0E47DF3"
            },
            {
                "walletAddress": "0x783c86dD618AeC69B641Eed24e84E352d7f4524c"
            },
            {
                "walletAddress": "0x26411855dc5dBB2EaeEAa956A116fbbAD79Dae3E"
            },
            {
                "walletAddress": "0x4dE9bce004A1C482b95EdA3212A6e8F12f8156C7"
            },
            {
                "walletAddress": "0x922aD9B1a85fb5774b83A0a6812c9A39B65eEf71"
            },
            {
                "walletAddress": "0xAabAcbFFb03F98bA5bB7208eEa2BA9f08Cb15F78"
            },
            {
                "walletAddress": "0x492C39cD947e6629c75a530533De833F54de145B"
            },
            {
                "walletAddress": "0x4f18130C83fdc8EB9a32d12cE24c71D2E7EC63B5"
            },
            {
                "walletAddress": "0xF18af57De6b95A9C5086cA6cC4275B67E5Bf8d6d"
            },
            {
                "walletAddress": "0x2747efb30A87021A600F36E1293a9B9D13CEeECA"
            },
            {
                "walletAddress": "0xd16eb4c8C362E64458483b0CbE94b4333b7c803e"
            },
            {
                "walletAddress": "0xBBA614f4223b3747e3824483BE81E7CD445E9F18"
            },
            {
                "walletAddress": "0xC074A019A8b931a14065d80Bba8128fF6C5e05d1"
            },
            {
                "walletAddress": "0xBc8C97Eb968c039689493a977Afff553b1f4738B"
            },
            {
                "walletAddress": "0xB1B59A93D2D5A26cb687F91be3D07DFaA6cFD03E"
            },
            {
                "walletAddress": "0x3d6B6741bc4588a63767D11f2858E5CEc52eeE3A"
            },
            {
                "walletAddress": "0x4b5bE06Bc1192A01bdAb176794Abf90AE0601251"
            },
            {
                "walletAddress": "0x05aa0a71936a8943e59229Fac5b4C3f5CcA6224D"
            },
            {
                "walletAddress": "0x7a18020dAc8f54cfF0a3dd4c41174E543bDB3417"
            },
            {
                "walletAddress": "0x025303731645Ee737841052A082777CFf0675d96"
            },
            {
                "walletAddress": "0x0abb22CB6885438bE00cE582f25a836582121E39"
            },
            {
                "walletAddress": "0x3b960eB6f7aaADD378F7cEa918f38366DD9B4369"
            },
            {
                "walletAddress": "0x3CB0d59E610b75F2C3FC5Ee5aB129C2b90Aa8343"
            },
            {
                "walletAddress": "0x5DA73f663164c9c5a9ABAFa179D4f76B58C5Db0B"
            },
            {
                "walletAddress": "0x7d30aA3D1518360aBc2Ed3e09E21651eC19fCdfB"
            },
            {
                "walletAddress": "0x21f2Dd627749E615B751410812b16B23fdb3f775"
            },
            {
                "walletAddress": "0x2c8e9E8051a37658e51FB894DDDdf94521573121"
            },
            {
                "walletAddress": "0xd3EBbDDC709eA19A1e31c18159cECFB05D074f6f"
            },
            {
                "walletAddress": "0x6d8f88594CF501B52f84e865950E42cFDDC2C789"
            },
            {
                "walletAddress": "0x30E7961f7930CFF58930DBcACb0Dc3362B827cC3"
            },
            {
                "walletAddress": "0x11804A366E0c35A87468014ee43C3CE748Ea4E84"
            },
            {
                "walletAddress": "0xF2323614257818A9267e28680a9839391CBdA217"
            },
            {
                "walletAddress": "0x189eC0ad9C0E9e8a2980af84C740B18d97e380B4"
            },
            {
                "walletAddress": "0xf00666163c61Ae9a2f7523DB5B7D00F597b4FBEd"
            },
            {
                "walletAddress": "0x2fBB54Dd444b7Ab53cC04b0d9E430db2bff40FE6"
            },
            {
                "walletAddress": "0x4de48d65cC88336D94682cE060960C549C108EC5"
            },
            {
                "walletAddress": "0x57b1C03DD4100A080eB65EdD991789C28B0867E3"
            },
            {
                "walletAddress": "0x92D9B50087736851Ad649fDC358707594ec27372"
            },
            {
                "walletAddress": "0x6F1Cbd6CC448eB7dB98fb723d74419FF5761729c"
            },
            {
                "walletAddress": "0x9e48d786046B49b6d27D11F44c0F955cA3119C00"
            },
            {
                "walletAddress": "0xcCc41a0D94718f1377045674B98351EbBdC6f977"
            },
            {
                "walletAddress": "0x41a1EF4D5b753f266d2107294A150C3bf66C8817"
            },
            {
                "walletAddress": "0xEC3565E464d420328c5eAfa63Fb695962677FdEf"
            },
            {
                "walletAddress": "0xF1a18a4E1F4B8a2184Db5ECea811b09E69cBa420"
            },
            {
                "walletAddress": "0xaeCf8503800374d4080c06d35aECcC1a955E6256"
            },
            {
                "walletAddress": "0x57f10dF5dc0cd5495c3F0C90Bf0A93a37FE7DaF2"
            },
            {
                "walletAddress": "0xcADDF3ac441B6fB53300687dBe637a44fD53965e"
            },
            {
                "walletAddress": "0x2Dcc1feE236f1e826d7a6F5D46F6890886BECd66"
            },
            {
                "walletAddress": "0x6dA299CB065A8672C33Ad0dd24b792d8d95F35e0"
            },
            {
                "walletAddress": "0xdaf60cCd4634f8314Ae7b30E185Ca52Ad9c6F6E1"
            },
            {
                "walletAddress": "0xedd93ed64cDC403F34cF7f171aD9cB995649C614"
            },
            {
                "walletAddress": "0x1FB57a4B65facEC9937F76a83910FdB30Be9e08C"
            },
            {
                "walletAddress": "0xa52C75a64051cbd216817c6dd376aC7A02A9BF7f"
            },
            {
                "walletAddress": "0x6940E240125edeeEe7588E15e1D78bA29893EFD0"
            },
            {
                "walletAddress": "0x38eD5081181A230960684cf873371332488623E0"
            },
            {
                "walletAddress": "0x2b55D6500d0d8E2F9B4a21Ef2b50b03B383634Ab"
            },
            {
                "walletAddress": "0x9aB6e95087e957af19e91160c3ade58bA9E21531"
            },
            {
                "walletAddress": "0xfC0D2F0c54B8f69A4AA57A090C7c48C84E5a1f67"
            },
            {
                "walletAddress": "0xb4Ba468797425611B7f7dDf2c8160CD8f33E93C8"
            },
            {
                "walletAddress": "0x4D1D008cd214Bf34696F508642A9534E15D3a6Ff"
            },
            {
                "walletAddress": "0x49A61D98803dfafa529F60f9490174c64A6fcEa4"
            },
            {
                "walletAddress": "0x01Ad2d8E8fF5FF36E71FcAE5dca8EF845947128D"
            },
            {
                "walletAddress": "0x63bCaCB5B63e11da4dA08f5aC0E0151B81a43DDe"
            },
            {
                "walletAddress": "0x327ec941eFAC4DaDcBFE767d7d55BfDCd64E9593"
            },
            {
                "walletAddress": "0x1b3442d83133a89f53fFE1Fd07c5a4B9bd546B11"
            },
            {
                "walletAddress": "0xc25cc370e82AC6C18089C01E10C1146400F91Ac9"
            },
            {
                "walletAddress": "0x21E529Cb81EE07f98b9634d81dc95E51B77102f6"
            },
            {
                "walletAddress": "0xcAA9d3d7C84a12E31E07b81413a6AF91Cd1a4334"
            },
            {
                "walletAddress": "0x3589A51A1381bF470A16685BfB4dD6e00f0b41B2"
            },
            {
                "walletAddress": "0xCC4BDedAb831A7e65769Cc23E8E814124A46116a"
            },
            {
                "walletAddress": "0x0c24f065E1217638Bc92a412EaC103C9c59243f5"
            },
            {
                "walletAddress": "0x069c626f31e4CD33e573F666A3f187b21BbaB9F2"
            },
            {
                "walletAddress": "0xC86Eb1F23c93D062eD6aD63396FfB41a45722003"
            },
            {
                "walletAddress": "0xc05894017734a7732ee1AEDa9Eb98C3e679f0Bf6"
            },
            {
                "walletAddress": "0xC875Bed087c758Dc49eAF04128DB55e37e059444"
            },
            {
                "walletAddress": "0x757C73Ef1e1B20fbaDc19E3aBB172d8461b825dC"
            },
            {
                "walletAddress": "0x8c01Af0766254dEBb5a4e1e5372597ebc1De5DBC"
            },
            {
                "walletAddress": "0xa34cA39ad2e08BDDE1aC3091a4C354D25a91Ca6D"
            },
            {
                "walletAddress": "0xCfA6B2Ba656FDA6167593Af6f72A46E84d4a8C58"
            },
            {
                "walletAddress": "0x7532724358553B24aC3147E018fE502CDe896E16"
            },
            {
                "walletAddress": "0xfe50040259A8372c57397151AB9CC246A25fa7E1"
            },
            {
                "walletAddress": "0x23280796944CE2f9BFC084AB93C09c210a4f1082"
            },
            {
                "walletAddress": "0xa85D8E524ef6da67338e87f29cDe9212CdF3a82b"
            },
            {
                "walletAddress": "0x6695b2162060E258A345aadCDb25fB4a389B5753"
            },
            {
                "walletAddress": "0x26B76a799f84e1397223cd9ee2c7b615e10A62Ba"
            },
            {
                "walletAddress": "0x792808aB891CC421369d2BC41B8253321996fBE4"
            },
            {
                "walletAddress": "0x48f5a7BEe36a0C0e1aFc099F4125C178DdcC24ed"
            },
            {
                "walletAddress": "0xd63063f1AebA40C6fa2DBE527Bc6bAAbd32C758c"
            },
            {
                "walletAddress": "0x104D24D32ff6Ca91391b10eB066B5Ee87a1F2cF6"
            },
            {
                "walletAddress": "0x7F6D45745f446E6841984262690555CA63ace396"
            },
            {
                "walletAddress": "0x8b299Bb558520c905C2d95cb147b5c19BDCC62e9"
            },
            {
                "walletAddress": "0x6378000098bdc97d8Ae4d41Ef4f849A53a86685B"
            },
            {
                "walletAddress": "0x9C981d03cD5FD99338E8eDCfDb57F37A4B0d5242"
            },
            {
                "walletAddress": "0x830292624DA77af16F23363dD874A8D941Ce377b"
            },
            {
                "walletAddress": "0xaa7828A4d966b776Be445E51471E25942E3b67f4"
            },
            {
                "walletAddress": "0x369824166ab0D3661326da34f6F60055997A8517"
            },
            {
                "walletAddress": "0xCc07dC6b0b1f7929994431069e338C69b8a8A38e"
            },
            {
                "walletAddress": "0xeEbEF5a8a0D0f4Ca3817223CF3095435Dae597Fb"
            },
            {
                "walletAddress": "0x220dd2EebFB257B28fC7D3374c250934bFd2830a"
            },
            {
                "walletAddress": "0xE86F4b7d3dEd298B008c06682ead3cBC19ca4c29"
            },
            {
                "walletAddress": "0xD19d48eF5355EC213cb25688a3934d1B836545D3"
            },
            {
                "walletAddress": "0x720bccd7e081Ccf24E8a8A52B1C2A04160910389"
            },
            {
                "walletAddress": "0x4c4CBe513c648425f8536848cDF40757A11fc370"
            },
            {
                "walletAddress": "0x1d7c73C78bDBad8e6C7147f582e751bf8A5c4E8c"
            },
            {
                "walletAddress": "0xA680772E39076FD326649c72aF7fc3f76B5cb006"
            },
            {
                "walletAddress": "0x8e6e8434Ba6215ad3AdcB1624033f0021B0011b7"
            },
            {
                "walletAddress": "0xf6262F1234B2ae062EEC7E40d16eA81D061Ace14"
            },
            {
                "walletAddress": "0xbBb2BeaD47CE0EE20CdFcAfA339C2C09abAe13E2"
            },
            {
                "walletAddress": "0x6DF38eFF2cC69f2d08cDA75305CEce1e76D7C3eD"
            },
            {
                "walletAddress": "0x9775DA61d245c1B03dDEEe15d83EDA5d2314265F"
            },
            {
                "walletAddress": "0x8AD5C6F0810dac207c20B86358e768722DbE6109"
            },
            {
                "walletAddress": "0x12245cCC82164c873D6a64079CF1b6374A8c1477"
            },
            {
                "walletAddress": "0x80cbA1883Ff94b8E2093a248fD358a18C50a754e"
            },
            {
                "walletAddress": "0xd682Df23AE210434743aD1c1e96fa545F85Cb98F"
            },
            {
                "walletAddress": "0x40934848A735B94b3a2FFf8427057728D9Bcef8F"
            },
            {
                "walletAddress": "0x0ed32Ae56deb3e3D50ab810060bC60C2dF05dB0c"
            },
            {
                "walletAddress": "0xC5C3Fe8b3B2473855c3369a53028289D682b4FFA"
            },
            {
                "walletAddress": "0xbeb827281214f364349F1665fe4024bF1eB6bc25"
            },
            {
                "walletAddress": "0xc113854f5dA17802b53355A411D42d20ec42F881"
            },
            {
                "walletAddress": "0xB4a935c27531Bfdf8beE8829bB3aABAFf3a576Dd"
            },
            {
                "walletAddress": "0xe5f8A0bF4B4DdF4A47D87FbB11a568c07d4983C2"
            },
            {
                "walletAddress": "0xb28768581F2c3E5eaF8420eC6Ca1629dFD007645"
            },
            {
                "walletAddress": "0xA331Ae4b944953ed3CAe8B888fa05F83718087cd"
            },
            {
                "walletAddress": "0x9BCa808Ec7C4f6a5226AD424b697741B4F0b9675"
            },
            {
                "walletAddress": "0xb205ff7104f335C07d366578e3B14D0C1b34Db78"
            },
            {
                "walletAddress": "0x8335e76c9444842C0BB06bb002F02fb0AD0bd7D8"
            },
            {
                "walletAddress": "0x64d3B17FE473bAf9cE4177ff92b51e38AD0e352a"
            },
            {
                "walletAddress": "0xbd40e25b44C58332b01A9B5f4E5f6487506C41A6"
            },
            {
                "walletAddress": "0xED220A1AE56395f99829Bd0efB74CE5eDf1113D8"
            },
            {
                "walletAddress": "0x2E0405371eDf45e16378FDf15FDE33FeDa9297E9"
            },
            {
                "walletAddress": "0x4dfd1d3da69f538f6FCb433D5656a7Bae914C5B0"
            },
            {
                "walletAddress": "0xeEaC56B1dE579d385f1fd0E0a1Da605a149FDB70"
            },
            {
                "walletAddress": "0x0bbCDca9f99414593afa3De124dB16B7D0Ebe532"
            },
            {
                "walletAddress": "0x362BD1F2C5D16f23248f885D7038b5F552FcD269"
            },
            {
                "walletAddress": "0x13Aa292C44F1A68Ec3ACD057F6E9cB3b3101902C"
            },
            {
                "walletAddress": "0x38dc320448972c76231e8B42F5aA1cA01153332E"
            },
            {
                "walletAddress": "0x624f2F791E51b8f8d336f216D1dD402452d8bd40"
            },
            {
                "walletAddress": "0x9ED1428F55808D094Dc206caf159F25ac1D37d48"
            },
            {
                "walletAddress": "0xf4D60B925C90650B6B5FEA6951eFbcB4E931391E"
            },
            {
                "walletAddress": "0xC993A76ceAfd02B205C05BcCdaB54FB7fDFDb4aF"
            },
            {
                "walletAddress": "0x10cBa3aE0d3D5d936Da7d09B2CF61a8ed543BedE"
            },
            {
                "walletAddress": "0x5C6D83E3613B6b62876A084f0379e1472B8deEe9"
            },
            {
                "walletAddress": "0x540E07e49a03CE51D0A05aEE9033821CfF03fc50"
            },
            {
                "walletAddress": "0xFeeC8897eF7ad9a4494FC0C7A06B5259FBbfB027"
            },
            {
                "walletAddress": "0x66C050C0De2E61E9E6762Cb55EFF8D529a9B2E8f"
            },
            {
                "walletAddress": "0x46746A0039C9F13F3BFbD6c51f7FdA95aC313f36"
            },
            {
                "walletAddress": "0x5f04188DBE2C0a98BcA3Ed60723924500d40cB3d"
            },
            {
                "walletAddress": "0xb1be705191cE7dAEb2BD9d779E6D292dd7ba4AAB"
            },
            {
                "walletAddress": "0x50B7bBF460808291390fB3F22157414C24F4227B"
            },
            {
                "walletAddress": "0x0aA27DBD8Dc86972DB6dF175f8c8064D7B7416D3"
            },
            {
                "walletAddress": "0xACd178b09FB19649471D5FD379091CA714c25a72"
            },
            {
                "walletAddress": "0x76636486EdF32E0A39fBb6f6393b8d2b9fabE0c3"
            },
            {
                "walletAddress": "0x55052899F573162b903137fbeD2128439099d103"
            },
            {
                "walletAddress": "0xef70D5Dd23617bD5D2721908ca74F2c2752aee08"
            },
            {
                "walletAddress": "0x90CA63610998F6Cb4375A6194ad594b5e7019878"
            },
            {
                "walletAddress": "0x29987c4Cb3B5DFbf498A9755A9871B671D39b7Ee"
            },
            {
                "walletAddress": "0xd661D26c0474ce6DDaa50B9744Ef9ca5D7d7175D"
            },
            {
                "walletAddress": "0x9f52ec4A5225dF56E7f1970AD98f98C2d71ffA6E"
            },
            {
                "walletAddress": "0x3F569AB878f7f67E7971a687a953789e4843B73b"
            },
            {
                "walletAddress": "0x898CB1fdeaE46146cD3fBA26CEf96d11cD374608"
            },
            {
                "walletAddress": "0xA66d2b24f2ABaDBD3b9DfF74D741A0a185AA4EF5"
            },
            {
                "walletAddress": "0x9Fda84e075315Ec93C9e8F61224bd2899146E505"
            },
            {
                "walletAddress": "0xc3A278d680FA4FDaDd8B5C9A209C183De861B59D"
            },
            {
                "walletAddress": "0xa25b19b53d355a567Aa6937f7d4909C59Ba8c610"
            },
            {
                "walletAddress": "0xBa086938DF582530a6ddD1551f91e40372958d43"
            },
            {
                "walletAddress": "0xb72127FDBcBb829dfE457c15FDfAE8591AEf49fa"
            },
            {
                "walletAddress": "0x1C4a3F1b21bEA8Db9ED25D08b16af7025A4c31F4"
            },
            {
                "walletAddress": "0x0879CfF34a085ab811E9822F81fF8E6bD325D627"
            },
            {
                "walletAddress": "0xba6D7281476fE85Aa328b5D2a945135Da1687173"
            },
            {
                "walletAddress": "0x15197b507FA7971320F7282Ef43c2DCf68f7D572"
            },
            {
                "walletAddress": "0x9021A08EFA85d831Bba37d840d50baF2eBdC5042"
            },
            {
                "walletAddress": "0x554BdcEb543d488741BA14AAa602Ea9577587fA2"
            },
            {
                "walletAddress": "0xd9a7f1b7a8B5d5CF08658F93f351d1233D0fACe0"
            },
            {
                "walletAddress": "0x75d059bC849126f20aD4dAED7A7831ee7840C140"
            },
            {
                "walletAddress": "0xE29362B8b127abB107b78433a3D79703F698116A"
            },
            {
                "walletAddress": "0x2F69bCE3cE2a4778434A67f6D311dC8Dc2c545f4"
            },
            {
                "walletAddress": "0x5DC125d300422d25bC957D5fC55B1fe46db1437b"
            },
            {
                "walletAddress": "0xeBA1c72790080E5d02723eaFF5975541908c7404"
            },
            {
                "walletAddress": "0x6Eb070C71816517DC938823151FF150575d062fD"
            },
            {
                "walletAddress": "0xB107C6bbD47A2F01f88Cd70c66cB552E3534886C"
            },
            {
                "walletAddress": "0xcF29Fab249F7d0f5FBab7c75B12C933DB4573B65"
            },
            {
                "walletAddress": "0x6292Fa3e6aa604B7293912a16508eF664BBB728e"
            },
            {
                "walletAddress": "0xF624898A9b4cf68f33D0FAb4B95813f670111629"
            },
            {
                "walletAddress": "0x5170eCA6af6858B37038cd291B42293B907A383D"
            },
            {
                "walletAddress": "0xbe8461E3960ED9e504e80D0Eaf30b582ea31EDb5"
            },
            {
                "walletAddress": "0x6f26C8948848C1741Ecc4CfFf6836F47AE1Dc916"
            },
            {
                "walletAddress": "0x24EC65eBB8144853640802E83ED8ee82a034fC95"
            },
            {
                "walletAddress": "0x419C5705fd11A871E3a5A51bCdC9536112bA6b2A"
            },
            {
                "walletAddress": "0xd70d987bce47485Fa854FFB1BA45A70Bf3E28667"
            },
            {
                "walletAddress": "0xfe235869C63959DC59B997D2C7e1863eCC148524"
            },
            {
                "walletAddress": "0x901C4A6E9381e0B884b0eA9d5c5101159A4F81Fe"
            },
            {
                "walletAddress": "0xb44449b3832807e90397602eb049dE28feA1831F"
            },
            {
                "walletAddress": "0x73683e6648a187424B17734d3C2427a27B6a90FA"
            },
            {
                "walletAddress": "0x0770babc5C6247dB6935F09023C65E2Bd936c08C"
            }
        ];
        const nft = new ParamControl(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        for (let i = 0; i < data.length; i++) {
            let key = data[i]['walletAddress'];
            key = key.toLowerCase();
            const val: any = await nft.getAddress(contract, key);
            console.log(i + 1, {"key": key, "val": val});
            // let tx = await nft.setAddress(contract, key, key, 0);
            // console.log("%s tx: %s", process.env.NETWORK, tx?.transactionHash, tx?.status);
        }

    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();