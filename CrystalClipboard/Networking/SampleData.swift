//
//  SampleData.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 8/20/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import Moya

extension CrystalClipboardAPI {
    static func testingProvider() -> MoyaProvider<CrystalClipboardAPI> {
        let endpointClosure = { (target: CrystalClipboardAPI) -> Endpoint<CrystalClipboardAPI> in
            return Endpoint<CrystalClipboardAPI>(
                url: URL(target: target).absoluteString,
                sampleResponseClosure: { .networkResponse(target.sampleStatusCode, target.sampleData) }
            )
        }
        return MoyaProvider<CrystalClipboardAPI>(endpointClosure: endpointClosure, stubClosure: MoyaProvider.immediatelyStub)
    }
    
    var sampleStatusCode: Int {
        switch self {
        case .createUser(let email, _):
            return email == "satan@hell.org" ? 422 : 201
        case .signIn, .me, .listClips: return 200
        case .signOut, .resetPassword, .deleteClip: return 204
        case .createClip: return 201
        }
    }
    
    var sampleData: Data {
        switch self {
        case .signOut, .resetPassword, .deleteClip: return Data()
        case .createUser(let email, _):
            if email == "satan@hell.org" {
                return "{\"errors\":[{\"source\":{\"pointer\":\"/data/attributes/email\"},\"detail\":\"has already been taken\"}]}".data(using: .utf8)!
            } else {
                return "{\"data\":{\"id\":\"\(arc4random_uniform(999) + 1)\",\"type\":\"users\",\"attributes\":{\"email\":\"\(email)\",\"token\":\"SE1QxtRifunhqeF75XVe7GBC\"}}}".data(using: .utf8)!
            }
        case .signIn:
            return "{\"data\":{\"id\":\"999\",\"type\":\"auth-tokens\",\"attributes\":{\"token\":\"Vy5KbYX116Y1him376FvAhkw\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},\"included\":[{\"id\":\"666\",\"type\":\"users\",\"attributes\":{\"email\":\"satan@hell.org\"}}]}".data(using: .utf8)!
        case .me:
            return "{\"data\":{\"id\":\"666\",\"type\":\"users\",\"attributes\":{\"email\":\"satan@hell.org\"}}}".data(using: .utf8)!
        case .listClips(let page, let pageSize):
            guard pageSize == 25 else { fatalError("There's only stubs for a pageSize of 25") }
            switch page {
            case 1:
                return "{\"data\":[{\"id\":\"9436\",\"type\":\"clips\",\"attributes\":{\"text\":\"ec1eb9d60c8d136ef1085810d0fe5117\",\"created-at\":\"2017-08-20T17:35:40.482Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9435\",\"type\":\"clips\",\"attributes\":{\"text\":\"cc73fc24d68ce6a479cea8293fd6028a\",\"created-at\":\"2017-08-20T17:35:40.478Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9434\",\"type\":\"clips\",\"attributes\":{\"text\":\"65ff6e8d0fd252f4109c32f711f7bde7\",\"created-at\":\"2017-08-20T17:35:40.476Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9433\",\"type\":\"clips\",\"attributes\":{\"text\":\"afcc20f74e332a8e0bed5e15d9d05cd8\",\"created-at\":\"2017-08-20T17:35:40.473Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9432\",\"type\":\"clips\",\"attributes\":{\"text\":\"fb820a166d279091d27d7aad2663df65\",\"created-at\":\"2017-08-20T17:35:40.470Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9431\",\"type\":\"clips\",\"attributes\":{\"text\":\"fd605bb1d3f86197251d9f440898c2a4\",\"created-at\":\"2017-08-20T17:35:40.466Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9430\",\"type\":\"clips\",\"attributes\":{\"text\":\"f68beb9e61d76e1421f5a1749b727a30\",\"created-at\":\"2017-08-20T17:35:40.463Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9429\",\"type\":\"clips\",\"attributes\":{\"text\":\"4a6218d3c67ed31f2abcea3c5fb99292\",\"created-at\":\"2017-08-20T17:35:40.461Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9428\",\"type\":\"clips\",\"attributes\":{\"text\":\"8248ce0c187987194f3b0af8f6fa14c9\",\"created-at\":\"2017-08-20T17:35:40.458Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9427\",\"type\":\"clips\",\"attributes\":{\"text\":\"33997b84f73ee2b4a72a02243fbd656d\",\"created-at\":\"2017-08-20T17:35:40.455Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9426\",\"type\":\"clips\",\"attributes\":{\"text\":\"d5b9ba70d00b5132c578742689a3c2ff\",\"created-at\":\"2017-08-20T17:35:40.452Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9425\",\"type\":\"clips\",\"attributes\":{\"text\":\"a59a8933a624591ddaebf78478da7de7\",\"created-at\":\"2017-08-20T17:35:40.450Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9424\",\"type\":\"clips\",\"attributes\":{\"text\":\"2615f11a63074fd19ee00d9533359863\",\"created-at\":\"2017-08-20T17:35:40.446Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9423\",\"type\":\"clips\",\"attributes\":{\"text\":\"24cf74b0949522c7a22b90d662852afa\",\"created-at\":\"2017-08-20T17:35:40.444Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9422\",\"type\":\"clips\",\"attributes\":{\"text\":\"66976631bffd30d57da5763a4114f5b1\",\"created-at\":\"2017-08-20T17:35:40.441Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9421\",\"type\":\"clips\",\"attributes\":{\"text\":\"099f6e3fff7e6235437e180dedd44d90\",\"created-at\":\"2017-08-20T17:35:40.438Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9420\",\"type\":\"clips\",\"attributes\":{\"text\":\"5159569aeb5849cd62fbc328135dee29\",\"created-at\":\"2017-08-20T17:35:40.435Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9419\",\"type\":\"clips\",\"attributes\":{\"text\":\"059febeb9dc6f69987f51689003bb626\",\"created-at\":\"2017-08-20T17:35:40.432Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9418\",\"type\":\"clips\",\"attributes\":{\"text\":\"aec3dd83f050bc5295b714c928736eec\",\"created-at\":\"2017-08-20T17:35:40.429Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9417\",\"type\":\"clips\",\"attributes\":{\"text\":\"d0c2f524826a803921dcbcc0ea922bc0\",\"created-at\":\"2017-08-20T17:35:40.427Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9416\",\"type\":\"clips\",\"attributes\":{\"text\":\"307c7cba1272a546509248041ba96193\",\"created-at\":\"2017-08-20T17:35:40.424Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9415\",\"type\":\"clips\",\"attributes\":{\"text\":\"d55499b0813a4458eea25432c29b72c6\",\"created-at\":\"2017-08-20T17:35:40.421Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9414\",\"type\":\"clips\",\"attributes\":{\"text\":\"55ced9e239272689d7a06c80eb9e3728\",\"created-at\":\"2017-08-20T17:35:40.418Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9413\",\"type\":\"clips\",\"attributes\":{\"text\":\"aef8fd7ae20d659e6bee16ea4d7819b1\",\"created-at\":\"2017-08-20T17:35:40.415Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9412\",\"type\":\"clips\",\"attributes\":{\"text\":\"1ce03e06844dcb69c3fdff872dc73cf8\",\"created-at\":\"2017-08-20T17:35:40.412Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}}],\"links\":{\"self\":\"https://www.crystalclipboard.com/api/v1/me/clips?page%5Bnumber%5D=1\\u0026page%5Bsize%5D=25\",\"next\":\"https://www.crystalclipboard.com/api/v1/me/clips?page%5Bnumber%5D=2\\u0026page%5Bsize%5D=25\",\"last\":\"https://www.crystalclipboard.com/api/v1/me/clips?page%5Bnumber%5D=4\\u0026page%5Bsize%5D=25\"},\"meta\":{\"current-page\":1,\"next-page\":2,\"prev-page\":null,\"total-pages\":4,\"total-count\":88}}".data(using: .utf8)!
            case 2:
                return "{\"data\":[{\"id\":\"9411\",\"type\":\"clips\",\"attributes\":{\"text\":\"162fe58337fe75c4dbd4bfeb2bbd1125\",\"created-at\":\"2017-08-20T17:35:40.409Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9410\",\"type\":\"clips\",\"attributes\":{\"text\":\"927df43e3b96321f02d339a911510700\",\"created-at\":\"2017-08-20T17:35:40.407Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9409\",\"type\":\"clips\",\"attributes\":{\"text\":\"1a608abfee0dda0a973b3e19bc1199da\",\"created-at\":\"2017-08-20T17:35:40.404Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9408\",\"type\":\"clips\",\"attributes\":{\"text\":\"c7eb16f6f73337a13cd8c90848727b5a\",\"created-at\":\"2017-08-20T17:35:40.401Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9407\",\"type\":\"clips\",\"attributes\":{\"text\":\"a6623cbd79f0fdae80a83adf43f58807\",\"created-at\":\"2017-08-20T17:35:40.398Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9406\",\"type\":\"clips\",\"attributes\":{\"text\":\"17f0e81458cc4034792719a74d00a109\",\"created-at\":\"2017-08-20T17:35:40.396Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9405\",\"type\":\"clips\",\"attributes\":{\"text\":\"401796bfa8ce81a2e1ed590bc3b1a949\",\"created-at\":\"2017-08-20T17:35:40.393Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9404\",\"type\":\"clips\",\"attributes\":{\"text\":\"c4308adbf7986b323aa45a86d29e6de2\",\"created-at\":\"2017-08-20T17:35:40.390Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9403\",\"type\":\"clips\",\"attributes\":{\"text\":\"cea076f91af59bebb7366c765eeef874\",\"created-at\":\"2017-08-20T17:35:40.388Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9402\",\"type\":\"clips\",\"attributes\":{\"text\":\"5f9088f570c0703fb331d4f832412bee\",\"created-at\":\"2017-08-20T17:35:40.385Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9401\",\"type\":\"clips\",\"attributes\":{\"text\":\"9f76b4eeed664c71a3c874d4eb1ab05a\",\"created-at\":\"2017-08-20T17:35:40.382Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9400\",\"type\":\"clips\",\"attributes\":{\"text\":\"c924834a0b1d9775dca22fb332c94cb7\",\"created-at\":\"2017-08-20T17:35:40.380Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9399\",\"type\":\"clips\",\"attributes\":{\"text\":\"63af463db3b2b0b3615d5c6575e6cce5\",\"created-at\":\"2017-08-20T17:35:40.377Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9398\",\"type\":\"clips\",\"attributes\":{\"text\":\"637c35cac97150e7f7d1d6f3a407e55a\",\"created-at\":\"2017-08-20T17:35:40.374Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9397\",\"type\":\"clips\",\"attributes\":{\"text\":\"aef627e8c042aa9695fe384c0b1b62b5\",\"created-at\":\"2017-08-20T17:35:40.371Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9396\",\"type\":\"clips\",\"attributes\":{\"text\":\"d5b8d8cfa79d6e3b02bbc0842c058aaa\",\"created-at\":\"2017-08-20T17:35:40.368Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9395\",\"type\":\"clips\",\"attributes\":{\"text\":\"6b74d167be5c747288e8e7e7915a8a98\",\"created-at\":\"2017-08-20T17:35:40.365Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9394\",\"type\":\"clips\",\"attributes\":{\"text\":\"8e7d7678cadfe5f2f4f0bf6e4248465f\",\"created-at\":\"2017-08-20T17:35:40.362Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9393\",\"type\":\"clips\",\"attributes\":{\"text\":\"1e0f290f1c9337c54ba0aa4f09d624ad\",\"created-at\":\"2017-08-20T17:35:40.360Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9392\",\"type\":\"clips\",\"attributes\":{\"text\":\"bf18d8cd336b02de27d703b8d25b4ac6\",\"created-at\":\"2017-08-20T17:35:40.357Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9391\",\"type\":\"clips\",\"attributes\":{\"text\":\"1e5825b5d16843d8cfae037e2229b3b7\",\"created-at\":\"2017-08-20T17:35:40.354Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9390\",\"type\":\"clips\",\"attributes\":{\"text\":\"89e96e63e0163e247c78c9aa8f4eed3f\",\"created-at\":\"2017-08-20T17:35:40.351Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9389\",\"type\":\"clips\",\"attributes\":{\"text\":\"4bf74cd7332893447bab56026337358d\",\"created-at\":\"2017-08-20T17:35:40.348Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9388\",\"type\":\"clips\",\"attributes\":{\"text\":\"6d3ce4e26d0fae707d013197a3c746bb\",\"created-at\":\"2017-08-20T17:35:40.346Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9387\",\"type\":\"clips\",\"attributes\":{\"text\":\"97df687e710735530d1a38394ffdba26\",\"created-at\":\"2017-08-20T17:35:40.343Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}}],\"links\":{\"self\":\"https://www.crystalclipboard.com/api/v1/me/clips?page%5Bnumber%5D=2\\u0026page%5Bsize%5D=25\",\"first\":\"https://www.crystalclipboard.com/api/v1/me/clips?page%5Bnumber%5D=1\\u0026page%5Bsize%5D=25\",\"prev\":\"https://www.crystalclipboard.com/api/v1/me/clips?page%5Bnumber%5D=1\\u0026page%5Bsize%5D=25\",\"next\":\"https://www.crystalclipboard.com/api/v1/me/clips?page%5Bnumber%5D=3\\u0026page%5Bsize%5D=25\",\"last\":\"https://www.crystalclipboard.com/api/v1/me/clips?page%5Bnumber%5D=4\\u0026page%5Bsize%5D=25\"},\"meta\":{\"current-page\":2,\"next-page\":3,\"prev-page\":1,\"total-pages\":4,\"total-count\":88}}".data(using: .utf8)!
            case 3:
                return "{\"data\":[{\"id\":\"9386\",\"type\":\"clips\",\"attributes\":{\"text\":\"574c45cec4f2cab287e5efb20d6b8c14\",\"created-at\":\"2017-08-20T17:35:40.340Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9385\",\"type\":\"clips\",\"attributes\":{\"text\":\"a365c0ace05e43c5d5148de1c8e3e796\",\"created-at\":\"2017-08-20T17:35:40.337Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9384\",\"type\":\"clips\",\"attributes\":{\"text\":\"a7c47990758111de87897c9481d9f8d0\",\"created-at\":\"2017-08-20T17:35:40.333Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9383\",\"type\":\"clips\",\"attributes\":{\"text\":\"9d7475e8ff7907bd1a674cf612641e05\",\"created-at\":\"2017-08-20T17:35:40.330Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9382\",\"type\":\"clips\",\"attributes\":{\"text\":\"5bbd03fa2a5c903afc54459728556665\",\"created-at\":\"2017-08-20T17:35:40.328Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9381\",\"type\":\"clips\",\"attributes\":{\"text\":\"d25bbb25ed0d356184a76aecaeda541d\",\"created-at\":\"2017-08-20T17:35:40.325Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9380\",\"type\":\"clips\",\"attributes\":{\"text\":\"61d3bde29d21f36683663cc7615d730b\",\"created-at\":\"2017-08-20T17:35:40.322Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9379\",\"type\":\"clips\",\"attributes\":{\"text\":\"d8b7adf4a2cfb90309dab0d708c48145\",\"created-at\":\"2017-08-20T17:35:40.319Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9378\",\"type\":\"clips\",\"attributes\":{\"text\":\"82c959f4474f9ccd69ee9624ad6a193a\",\"created-at\":\"2017-08-20T17:35:40.316Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9377\",\"type\":\"clips\",\"attributes\":{\"text\":\"5253f3a2abf5ed245f0e5f4ec91007e7\",\"created-at\":\"2017-08-20T17:35:40.313Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9376\",\"type\":\"clips\",\"attributes\":{\"text\":\"48ef77d4f49a94be452fccaf24a86990\",\"created-at\":\"2017-08-20T17:35:40.306Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9375\",\"type\":\"clips\",\"attributes\":{\"text\":\"9f61b812627092d4b0e7e063b6274cd0\",\"created-at\":\"2017-08-20T17:35:40.303Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9374\",\"type\":\"clips\",\"attributes\":{\"text\":\"c481ecdd74f62a6dc5f227b4d0f0136d\",\"created-at\":\"2017-08-20T17:35:40.300Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9373\",\"type\":\"clips\",\"attributes\":{\"text\":\"0cf7a9aba2be02cab4d98eef8fc4a6ae\",\"created-at\":\"2017-08-20T17:35:40.297Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9372\",\"type\":\"clips\",\"attributes\":{\"text\":\"61fb0b47fc03cdba4c9f6664efa39f6a\",\"created-at\":\"2017-08-20T17:35:40.295Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9371\",\"type\":\"clips\",\"attributes\":{\"text\":\"ba1aa4fa3177718bccb1701b5b8b24e6\",\"created-at\":\"2017-08-20T17:35:40.291Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9370\",\"type\":\"clips\",\"attributes\":{\"text\":\"c96c0e027850d413921f310e7307f77c\",\"created-at\":\"2017-08-20T17:35:40.289Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9369\",\"type\":\"clips\",\"attributes\":{\"text\":\"ecff7e85127b980c76f9df89afea5cc6\",\"created-at\":\"2017-08-20T17:35:40.286Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9368\",\"type\":\"clips\",\"attributes\":{\"text\":\"82fa0c484fd0c6991ae60845d685d6b7\",\"created-at\":\"2017-08-20T17:35:40.283Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9367\",\"type\":\"clips\",\"attributes\":{\"text\":\"4101163127ddde7226cb92985cfe0ce4\",\"created-at\":\"2017-08-20T17:35:40.280Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9366\",\"type\":\"clips\",\"attributes\":{\"text\":\"e1682ab77471dd912a15f1689614d4f0\",\"created-at\":\"2017-08-20T17:35:40.277Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9365\",\"type\":\"clips\",\"attributes\":{\"text\":\"4fe6679ba15672cdfb68335f379c3429\",\"created-at\":\"2017-08-20T17:35:40.274Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9364\",\"type\":\"clips\",\"attributes\":{\"text\":\"da20d47aacaab72a9c60e4de9419c4ee\",\"created-at\":\"2017-08-20T17:35:40.271Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9363\",\"type\":\"clips\",\"attributes\":{\"text\":\"3f1dc4345361aca6176b4f9e2d706eef\",\"created-at\":\"2017-08-20T17:35:40.268Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9362\",\"type\":\"clips\",\"attributes\":{\"text\":\"6485ee6bc027b37af3e65078f7e66c93\",\"created-at\":\"2017-08-20T17:35:40.265Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}}],\"links\":{\"self\":\"https://www.crystalclipboard.com/api/v1/me/clips?page%5Bnumber%5D=3\\u0026page%5Bsize%5D=25\",\"first\":\"https://www.crystalclipboard.com/api/v1/me/clips?page%5Bnumber%5D=1\\u0026page%5Bsize%5D=25\",\"prev\":\"https://www.crystalclipboard.com/api/v1/me/clips?page%5Bnumber%5D=2\\u0026page%5Bsize%5D=25\",\"next\":\"https://www.crystalclipboard.com/api/v1/me/clips?page%5Bnumber%5D=4\\u0026page%5Bsize%5D=25\",\"last\":\"https://www.crystalclipboard.com/api/v1/me/clips?page%5Bnumber%5D=4\\u0026page%5Bsize%5D=25\"},\"meta\":{\"current-page\":3,\"next-page\":4,\"prev-page\":2,\"total-pages\":4,\"total-count\":88}}".data(using: .utf8)!
            case 4:
                return "{\"data\":[{\"id\":\"9361\",\"type\":\"clips\",\"attributes\":{\"text\":\"649bbb7a69bf65a12d27d85c63650ae9\",\"created-at\":\"2017-08-20T17:35:40.262Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9360\",\"type\":\"clips\",\"attributes\":{\"text\":\"353c7ff6eea8fe36599a072171b963cc\",\"created-at\":\"2017-08-20T17:35:40.259Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9359\",\"type\":\"clips\",\"attributes\":{\"text\":\"b36e07dadb765a83ce439c4389f7c691\",\"created-at\":\"2017-08-20T17:35:40.256Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9358\",\"type\":\"clips\",\"attributes\":{\"text\":\"aee3bc468f2407ddaaed62e57073f45b\",\"created-at\":\"2017-08-20T17:35:40.253Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9357\",\"type\":\"clips\",\"attributes\":{\"text\":\"17b0260e22da208553a98498cac1f0ce\",\"created-at\":\"2017-08-20T17:35:40.251Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9356\",\"type\":\"clips\",\"attributes\":{\"text\":\"3fe9cfc85edf936db673126cd77baed5\",\"created-at\":\"2017-08-20T17:35:40.248Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9355\",\"type\":\"clips\",\"attributes\":{\"text\":\"0ca375fb1410abf180be6a52d633967f\",\"created-at\":\"2017-08-20T17:35:40.245Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9354\",\"type\":\"clips\",\"attributes\":{\"text\":\"08bd6be98806db0662233b5a4752d5b4\",\"created-at\":\"2017-08-20T17:35:40.243Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9353\",\"type\":\"clips\",\"attributes\":{\"text\":\"f282466bbe1b8ab3cfda6d40dba030ae\",\"created-at\":\"2017-08-20T17:35:40.240Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9352\",\"type\":\"clips\",\"attributes\":{\"text\":\"5259eec13cf0433e7a7569b53521a9ce\",\"created-at\":\"2017-08-20T17:35:40.237Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9351\",\"type\":\"clips\",\"attributes\":{\"text\":\"9c9d3275c1f86a42739c486643718bd3\",\"created-at\":\"2017-08-20T17:35:40.233Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9350\",\"type\":\"clips\",\"attributes\":{\"text\":\"a3e0ff2092b05f290c06e3d2bc3f1afd\",\"created-at\":\"2017-08-20T17:35:40.230Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}},{\"id\":\"9349\",\"type\":\"clips\",\"attributes\":{\"text\":\"7a2f85c54441930c22227f41ff95f5c5\",\"created-at\":\"2017-08-20T17:35:40.195Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}}],\"links\":{\"self\":\"https://www.crystalclipboard.com/api/v1/me/clips?page%5Bnumber%5D=4\\u0026page%5Bsize%5D=25\",\"first\":\"https://www.crystalclipboard.com/api/v1/me/clips?page%5Bnumber%5D=1\\u0026page%5Bsize%5D=25\",\"prev\":\"https://www.crystalclipboard.com/api/v1/me/clips?page%5Bnumber%5D=3\\u0026page%5Bsize%5D=25\"},\"meta\":{\"current-page\":4,\"next-page\":null,\"prev-page\":3,\"total-pages\":4,\"total-count\":88}}".data(using: .utf8)!
            default: fatalError("There are only stubs for 4 pages")
            }
        case .createClip(let text):
            return "{\"data\":{\"id\":\"5659\",\"type\":\"clips\",\"attributes\":{\"text\":\"\(text)\",\"created-at\":\"2017-08-20T16:33:52.100Z\"},\"relationships\":{\"user\":{\"data\":{\"id\":\"666\",\"type\":\"users\"}}}}}".data(using: .utf8)!
        }
    }
}
