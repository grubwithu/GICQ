
import UIKit

class TableViewCell:UITableViewCell
{
    //消息内容视图
    var customView:UIView!
    //消息背景
    var bubbleImage:UIImageView!
    //头像
    var avatarImage:UIImageView!
    //消息数据结构
    var msgItem:MessageItem!
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
    }
    
    //- (void) setupInternalData
    init(data:MessageItem, reuseIdentifier cellId:String)
    {
        self.msgItem = data
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier:cellId)
        rebuildUserInterface()
    }
    
    func rebuildUserInterface()
    {
        
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        if (self.bubbleImage == nil)
        {
            self.bubbleImage = UIImageView()
            self.addSubview(self.bubbleImage)
            
        }
        
        var type =  self.msgItem.mtype
        var width =  self.msgItem.view.frame.size.width
        
        var height =  self.msgItem.view.frame.size.height
        
        var x =  (type == ChatType.Someone) ? 10 : self.frame.size.width - width -
            self.msgItem.insets.left - self.msgItem.insets.right - 10
        
        var y:CGFloat =  5.0
        //显示用户头像
        if (self.msgItem.logo != "")
        {
            self.avatarImage = UIImageView(image:UIImage(systemName: "person.fill"))
            
            self.avatarImage.layer.cornerRadius = 7.0
            self.avatarImage.layer.masksToBounds = true
            self.avatarImage.layer.borderColor = UIColor(white:0.0 ,alpha:0.2).cgColor
            self.avatarImage.layer.borderWidth = 0.5
            
            //别人头像，在左边，我的头像在右边
            var avatarX =  (type == ChatType.Someone) ? 15 : self.frame.size.width
            
            //头像居于消息底部
            var avatarY =  5.0
            //set the frame correctly
            self.avatarImage.frame = CGRectMake(avatarX, avatarY, 50, 50)
            self.addSubview(self.avatarImage)
            
            
            var delta =  self.frame.size.height - (self.msgItem.insets.top + self.msgItem.insets.bottom
                + self.msgItem.view.frame.size.height)
            if (delta > 0)
            {
                y = delta
            }
            if (type == ChatType.Someone)
            {
                x += 60
            }
            if (type == ChatType.Mine)
            {
                x -= -10
            }
        }
        
        self.customView = self.msgItem.view
        self.customView.frame = CGRectMake(x + self.msgItem.insets.left, y + self.msgItem.insets.top, width, height)
        
        self.addSubview(self.customView)
        
        //如果是别人的消息，在左边，如果是我输入的消息，在右边
        if (type == ChatType.Someone)
        {
            self.bubbleImage.image = UIImage(named: "someone")
            self.bubbleImage.frame = CGRectMake(x + 5, y - 1, width + self.msgItem.insets.left
                + self.msgItem.insets.right, height + self.msgItem.insets.top + self.msgItem.insets.bottom)
        }
        else {
            self.bubbleImage.image = UIImage(named: "me")
            self.bubbleImage.frame = CGRectMake(x - 10, y - 1, width + self.msgItem.insets.left
                + self.msgItem.insets.right, height + self.msgItem.insets.top + self.msgItem.insets.bottom)
        }

    }
}
