
import UIKit

//消息类型，我的还是别人的
enum ChatType
{
    case Mine
    case Someone
}

class MessageItem
{
    //内容
    var content:String
    //头像
    var logo:String
    //消息时间
    var date:NSDate
    //消息类型
    var mtype:ChatType
    //内容视图，标签或者图片
    var view:UIView
    //边距
    var insets:UIEdgeInsets
    
    //设置我的文本消息边距
    class func getTextInsetsMine() -> UIEdgeInsets
    {
        return UIEdgeInsets(top:5, left:10, bottom:11, right:17)
    }
    
    //设置他人的文本消息边距
    class func getTextInsetsSomeone() -> UIEdgeInsets
    {
        return UIEdgeInsets(top:5, left:15, bottom:11, right:10)
    }
    
    //设置我的图片消息边距
    class func getImageInsetsMine() -> UIEdgeInsets
    {
        return UIEdgeInsets(top:11, left:13, bottom:16, right:22)
    }
    
    //设置他人的图片消息边距
    class func getImageInsetsSomeone() -> UIEdgeInsets
    {
        return UIEdgeInsets(top:11, left:13, bottom:16, right:22)
    }
    
    //构造文本消息体
    convenience init(body:NSString, logo:String, date:NSDate, mtype:ChatType)
    {
        var font =  UIFont.boldSystemFont(ofSize: 12)
        
        var width =  225, height = 10000.0
        
        var atts =  NSMutableDictionary()
        atts.setObject(font,forKey:NSAttributedString.Key.font as NSCopying)
        
        var size =  body.boundingRect(with: CGSizeMake(CGFloat(width), CGFloat(height)),
                                      options:NSStringDrawingOptions.usesLineFragmentOrigin, attributes:atts as! [NSAttributedString.Key : Any], context:nil)
        
        var label =  UILabel(frame:CGRectMake(0, 0, size.size.width, size.size.height))
        
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.text = (body.length != 0 ? body as String : "")
        label.font = font
        label.backgroundColor = UIColor.clear
        
        var insets:UIEdgeInsets =  (mtype == ChatType.Mine ?
            MessageItem.getTextInsetsMine() : MessageItem.getTextInsetsSomeone())
        
        self.init(logo:logo, date:date, mtype:mtype, view:label, insets:insets)
        content = String(body)
    }
    
    //可以传入更多的自定义视图
    init(logo:String, date:NSDate, mtype:ChatType, view:UIView, insets:UIEdgeInsets)
    {
        self.view = view
        self.logo = logo
        self.date = date
        self.mtype = mtype
        self.insets = insets
        content = "[Other]"
    }
    
    //构造图片消息体
    convenience init(image:UIImage, logo:String,  date:NSDate, mtype:ChatType)
    {
        var size = image.size
        //等比缩放
        if (size.width > 220)
        {
            size.height /= (size.width / 220);
            size.width = 220;
        }
        var imageView = UIImageView(frame:CGRectMake(0, 0, size.width, size.height))
        imageView.image = image
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        
        var insets:UIEdgeInsets =  (mtype == ChatType.Mine ?
            MessageItem.getImageInsetsMine() : MessageItem.getImageInsetsSomeone())
        
        self.init(logo:logo,  date:date, mtype:mtype, view:imageView, insets:insets)
        content = "[Image]"
    }    
}
