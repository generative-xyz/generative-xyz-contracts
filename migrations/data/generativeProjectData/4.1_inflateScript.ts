import * as dotenv from 'dotenv';

import {ethers} from "ethers";
import * as fs from "fs";
import {keccak256} from "ethers/lib/utils";
import Web3 from "web3";
import {createAlchemyWeb3} from "@alch/alchemy-web3";
import {GenerativeProjectData} from "./generativeProjectData";

const hardhatConfig = require("../../../hardhat.config");

(async () => {
    try {
        if (process.env.NETWORK != "local") {
            console.log("wrong network");
            return;
        }
        const data = new GenerativeProjectData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
        const args = process.argv.slice(2)
        const html = await data.inflateScript(args[0], '<script>rFZtb9u2E/8qhoAapMTIsv91/5tdduiyFgvQYkFbYA2KvqClq0WEJjWSiu06/u4DKcl6iLMG2N7p7sfj3f3ugUqVNHaU0kyl5QakjVMNzMIbAU5CQcrkHTMBXp4OrFS2jwsNBcgMpXgpwI40kxndMJt/YDJDePmtlKnlSo7WYJ1Kba6kRUAsPmiwpZYjiN4zm8ffhFIaOfMQ2QuIphgfHxq/FYp5cyLxoYrY0NYKR4Bjq97yHWRI4mXtomDaQGVqOrc6s9das/3wQohsYyq/mGcyFiDXNv96dBmmSihNe+lMyTRJMDGWafsAmWOSqXIlYIg8x8s7pkdbmsZbntmcbrnM1DbmUoL+02lITtM4B77ObQ/83atIanc0jddgL5W0sLMomGUBJqqwhh4EyEXf4ZzM5pikqpS2jzxPyIsEkxUz8IlvoA/+TKZTTFiWQfYYmHG4zJlMYREnc2IKtpW1PHWSvm3QWvyNm0EEczJ1/DnwI/8OixnxLC+C3AiUl0CCqHf+f4lnPAqeEeGoeIYDH/47JyzmSRVvJZ0J2OQsU9tPyiV0rVXxvhQPAvo/bm+8kkVp3SFeCA56ESfTjoeH6Iyku8V24vshrIpP0v0i72s0FIxL+1oUOVsMOtx5iJOfMMlLz+0aFq5bj8Ty9JYmRHAJhn756rj/TLeT2cRV3fWp09zQvKtxeXxgGfVzdn0VziYvlqndxd+4EB/tXgANVoKltwFptB8gtSghCdmSvDPDQqkC4UPdihr+KsHY15JvmIPfarYB5M5gEkUuUH/fWqgVE5dqUyjDLfxRgPbHaWBUqVO4UHegK9dVXX4VpaYJGUSo1yuGBm2QkNl8jqNg2B4/1DNR4CDWUAiWAgqYKAI/NnG3Jvg8HT9IyvejS8iXqN4cL/3lfvTGY18G7YNCuEI6MzMeV4ZFaXIkYTt6xyXg+rYNK1BTDQT4ALGxUCB87Gw1dx7hg825S8eARfjodHGhlVV2X0ClpqeL6sM7mhD/sW8+fI9/7kk3jaRZ1nyKM1NAfV6PTVDk0UdHKOxRVDmp1m7No1C6rV5eQuDnIvToaWIaw3JTCmb5nV9uTcwrWHN5nTMDCB/JgJ8WfEhSRDvU1Hx1dTeVznZ8WabXYL33EytO6rDgxH7W9y3PEa0nOET93onnv0wXF1Pcq5Y/kiqDGnPcK5+HDZcdGJ3pyNNOv7+v8n7lNk0jvLzoSHsH3TSCh27weNxrwCHDrm273EbRiTVSf/fr1rL6ig5IrV11K+ofVqAnm8nAhNiWh5r366vJDBPZrW5oielWNrTLwZaCquXOvSeD/dUaXvpGbnu6bWQ/R/UiOk3OcFTCfgH7LIWPziMebLNqkHYRqrta4vD0XlTYvsb2kelgMzLD5PwGa9758fipnqLeRWF7kftDeKzZL9pj7l9hMvuneP9LDyfFQMRHUj2MpH4YWZa9uQNp33FjQYJGgQbDv0NAOh3/r377nvp019Ts3B9CQ5P7N3jKb8MR/x0AAP//</script>');
        console.log(html);
    } catch (e) {
        // Deal with the fact the chain failed
        console.log(e);
    }
})();