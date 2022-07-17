import {SendRequest} from "@reef-defi/extension-base/page/types";
import Accounts from "@reef-defi/extension-base/page/Accounts";
import Metadata from "@reef-defi/extension-base/page/Metadata";
import PostMessageProvider from "@reef-defi/extension-base/page/PostMessageProvider";
import Injected from "@reef-defi/extension-base/page/Injected";
import Signer from "@reef-defi/extension-base/page/Signer";

export default class implements Injected {
    public readonly accounts: Accounts;

    public readonly metadata: Metadata;

    public readonly provider: PostMessageProvider;

    public readonly signer: Signer;

    constructor (sendRequest: SendRequest, sigKey: Signer) {
        this.accounts = new Accounts(sendRequest);
        this.metadata = new Metadata(sendRequest);
        this.provider = new PostMessageProvider(sendRequest);
        this.signer = sigKey;
    }
}
