enum AppIcons: String, CaseIterable {
  case cash
  case wechat
  case alipay
  case paypal
  case qq
  case jd
  case tiktok
  case duoduo
  case baitiao
  case jdmark
  case jdecard
  case meituan
  case rmb
  case txlct
  case wechatlqt
  case yuebao
  case yulibao
  case yunshanfu
  case ant
  case gongshangbank
  case guangdabank
  case guangfabank
  case guojiakaifabank
  case huifengbank
  case jianshebank
  case pinganbank
  case shengjingbank
  case weizhongbank
  case youzhengbank
  case zhadabank
  case zhaoshangbank
  case renbank
  case zhongguobank
  case otherbank
  case house
  case gold
  case reciveable
  case creditcard
  case car
  case debet
  case financemanage
  case fund
  case insurance
  case wallet
  case netwallet
  case stock
  case fixedasset
  case asset
  case light
  case bill
  case transfer

  // Computed property to return the icon file name

  var file: String {
    switch self {
    case .cash: return "account_现金"
    case .wechat: return "account_wechat"
    case .alipay: return "account_alipay"
    case .paypal: return "account_paypal"
    case .qq: return "account_qq"
    case .jd: return "account_jd"
    case .tiktok: return "account_抖音钱包"
    case .duoduo: return "account_多多钱包"
    case .baitiao: return "account_京东白条"
    case .jdmark: return "account_京东超市卡"
    case .jdecard: return "account_京东E卡"
    case .meituan: return "account_美团钱包"
    case .rmb: return "account_数字人民币"
    case .txlct: return "account_腾讯理财通"
    case .wechatlqt: return "account_微信零钱通"
    case .yuebao: return "account_余额宝"
    case .yulibao: return "account_余利宝"
    case .yunshanfu: return "account_云闪付"
    case .ant: return "account_ant"
    case .gongshangbank: return "工商银行"
    case .guangdabank: return "光大银行"
    case .guangfabank: return "广发银行"
    case .guojiakaifabank: return "国家开发银行"
    case .huifengbank: return "汇丰银行"
    case .jianshebank: return "建设银行"
    case .pinganbank: return "平安银行"
    case .shengjingbank: return "盛京银行"
    case .weizhongbank: return "微众银行"
    case .youzhengbank: return "邮政储蓄银行"
    case .zhadabank: return "渣打银行"
    case .zhaoshangbank: return "招商银行"
    case .renbank: return "中国人民银行"
    case .zhongguobank: return "中国银行"
    case .otherbank: return "银行卡"
    case .house: return "房产"
    case .gold: return "黄金"
    case .reciveable: return "account_应收款项"
    case .creditcard: return "account_信用卡"
    case .car: return "account_汽车"
    case .debet: return "account_负债"
    case .financemanage: return "account_理财"
    case .fund: return "account_基金"
    case .insurance: return "account_保险"
    case .wallet: return "account_钱包"
    case .netwallet: return "account_网络钱包"
    case .stock: return "account_股票"
    case .fixedasset: return "account_固定资产"
    case .asset: return "资产"
    case .light: return "电灯泡"
    case .bill: return "account_list"
    case .transfer: return "转账"
    }
  }
}
