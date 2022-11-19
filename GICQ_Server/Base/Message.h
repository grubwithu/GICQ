//
// Created by Grub on 2022/11/14.
//

#ifndef GICQ_SERVER_MESSAGE_H
#define GICQ_SERVER_MESSAGE_H

#include <string>

class Message {
public:
    std::string senderID;
    std::string receiverID;
    std::string content;
    Message(const std::string &senderId, const std::string &receiverId, const std::string &content) : senderID(
            senderId), receiverID(receiverId), content(content) {}
};


#endif //GICQ_SERVER_MESSAGE_H
