//
// Created by Mikhail Jax on 2022/10/11.
//

#ifndef GICQ_SERVER_SERVER_H
#define GICQ_SERVER_SERVER_H

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <vector>
#include <list>
#include <map>
#include <thread>
#include "UserInfo.h"
#include "Message.h"

class Server {
    int _port;
    bool linkEstablished = false;
    std::vector<std::thread> threads;
    int _sock_fd;
    sockaddr_in _addr;
    int threadID = 0;

    std::list<Message> messagesPool;
    std::map<std::string, UserInfo> users;


    void createSocket() throw(int);
    std::string processMsg(char* msg, std::string& userID);
    std::vector<std::pair<std::string, std::string>> strToMsg(char* msg);
    std::string msgToStr(std::vector<std::pair<std::string, std::string>>);
public:
    Server(int port);
    void start();
};

#endif //GICQ_SERVER_SERVER_H
