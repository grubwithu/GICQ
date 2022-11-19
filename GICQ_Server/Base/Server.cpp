//
// Created by Mikhail Jax on 2022/10/11.
//

#include "Server.h"
#include <iostream>
#include <string.h>

#define Messages std::vector<std::pair<std::string, std::string>>

constexpr std::uint32_t HASH(const char* data)
{
    std::uint32_t h(0);
    for (int i = 0; data && ('\0' != data[i]); i++)
        h = (h << 6) ^ (h >> 26) ^ data[i];
    return h;
}

Server::Server(int port) {
    _port = port;
    try {
        createSocket();
    } catch (int errorCode) {
        switch (errorCode) {
            case -1:
                std::cout << "Failed to create socket.\n";
                break;
            case -2:
                std::cout << "Failed to bind.\n";
                break;
            case -3:
                std::cout << "Failed to begin listen.\n";
                break;
            default:
                linkEstablished = true;
                threads = std::vector<std::thread>();
        }
    }
}

void Server::createSocket() throw(int) {
    _sock_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (_sock_fd < 0) {
        throw -1;
    }
    socklen_t addrlen = sizeof(sockaddr_in);
    bzero(&_addr, addrlen);
    _addr.sin_family = AF_INET;
    _addr.sin_addr.s_addr = htonl(INADDR_ANY);
    _addr.sin_port = htons(_port);
    if (bind(_sock_fd, (sockaddr*)&_addr, sizeof(struct sockaddr_in)) < 0) {
        throw -2;
    }
    if (listen(_sock_fd, 5) < 0) {
        throw -3;
    }
}

void Server::start() {
    sockaddr_in client_addr;
    socklen_t client_t;
    while(true) {
        int client_socket = accept(_sock_fd, (sockaddr*)&client_addr, &client_t);
        if (client_socket <= 0) {
            std::cout << "Failed to accept the connection.\n ";
        } else {
            threads.push_back(std::thread([&](){
                int id = this->threadID++;
                std::cout << "[Thread " << id << "]: Connection Established!" << std::endl;
                int socket = client_socket;
                char* msg = new char[1024];
                std::string userID = "";
                while(true) {
                    if(recv(socket, msg, static_cast<size_t>(1024), 0))
                    {
                        std::cout << "[Thread " << id << "]: Received Messages: " << msg << "\n";
                        std::string sendMsg = processMsg(msg, userID);
                        send(socket, sendMsg.data(), static_cast<size_t>(sendMsg.size()+1), 0);
                        std::cout << "[Thread " << id << "]: Send Messages: " << sendMsg << "\n";
                    }
                    else {
                        std::cout << "[Thread " << id << "]: Disconnected.\n";
                        break;
                    }
                    bzero(msg, 1024);
                }
            }));
        }
    }
}

std::string Server::processMsg(char *msg, std::string& userID) {
    Messages args = strToMsg(msg);
    Messages ans;
    switch(HASH(args[0].first.data())) {
        case HASH("LOGIN"): {
            if (args.size() != 3 || args[0].second != "LOGIN" || args[1].first != "ACCOUNT" || args[2].first != "PASSWORD") { // false
                ans.push_back(std::pair<std::string, std::string>("LOGIN", "FAILED"));
                ans.push_back(std::pair<std::string, std::string>("REASON", "OTHER_ERROR"));
            } else {
                auto user = users.find(args[1].second);
                if (user == users.end()) { // account not found
                    ans.push_back({"LOGIN", "FAILED"});
                    ans.push_back({"REASON", "ACCOUNT_NOT_FOUND"});
                } else if (user->second.pwd != args[2].second) { // password wrong
                    ans.push_back({"LOGIN", "FAILED"});
                    ans.push_back({"REASON", "INCORRECT_PASSWORD"});
                } else {
                    ans.push_back({"LOGIN", "SUCCESS"});
                    userID = user->second.id;
                }
            }
            break;
        }
        case HASH("REGISTER"): {
            if (args.size() != 5 || args[0].second != "REGISTER" || args[1].first != "ACCOUNT" ||
                args[2].first != "PASSWORD" || args[3].first != "NAME" || args[4].first != "TIME") {
                ans.push_back(std::pair<std::string, std::string>("REGISTER", "FAILED"));
                ans.push_back(std::pair<std::string, std::string>("REASON", "OTHER_ERROR"));
            } else {
                auto user = users.find(args[1].second);
                if (user == users.end()) {
                    users[args[1].second] = UserInfo(args[3].second, args[1].second, args[2].second, args[4].second);
                    ans.push_back({"REGISTER", "SUCCESS"});
                } else {
                    ans.push_back({"REGISTER", "FAILED"});
                    ans.push_back({"REASON", "ID_HAS_BEEN_REGISTERED"});
                }
            }
            break;
        }
        case HASH("USERINFO"): {
            if (args.size() != 1 || args[0].second != "GET" || userID == "") {
                ans.push_back(std::pair<std::string, std::string>("USERINFO", "FAILED"));
                ans.push_back(std::pair<std::string, std::string>("REASON", "OTHER_ERROR"));
            } else {
                ans.push_back({"USERINFO", "RETURN"});
                ans.push_back({"ACCOUNT", users[userID].id});
                ans.push_back({"NAME", users[userID].name});
                ans.push_back({"REGISTERDATE", users[userID].registerDate});
            }
            break;
        }
        case HASH("CHAT"): {
            if (args.size() != 3 || args[0].second != "SEND" || args[1].first != "ACCOUNT" || args[2].first != "CONTENT") {
                ans.push_back(std::pair<std::string, std::string>("CHAT", "FAILED"));
                ans.push_back(std::pair<std::string, std::string>("REASON", "OTHER_ERROR"));
            } else {
                if (args[1].second == userID) {
                    ans.push_back({"CHAT", "FAILED"});
                    ans.push_back({"REASON", "SENDER_IS_SELF"});
                } else {
                    auto user = users.find(args[1].second);
                    if (user == users.end()) {
                        ans.push_back({"CHAT", "FAILED"});
                        ans.push_back({"REASON", "ACCOUNT_NOT_FOUND"});
                    } else {
                        messagesPool.push_back(Message(userID, args[1].second, args[2].second));
                        ans.push_back({"CHAT", "SUCCESS"});
                        ans.push_back({"NAME", user->second.name});
                    }
                }
            }
            break;
        }
        case HASH("GETCHAT"): {
            if (args.size() != 1 || args[0].second != "GETCHAT") {
                ans.push_back(std::pair<std::string, std::string>("CHAT", "FAILED"));
                ans.push_back(std::pair<std::string, std::string>("REASON", "OTHER_ERROR"));
            } else {
                int num = 0;
                for (auto it = messagesPool.begin(); it != messagesPool.end(); ) {
                    if ((*it).receiverID == userID) {
                        ans.push_back({"CHAT_SENDER", it->senderID});
                        ans.push_back({"CHAT_NAME", users[it->senderID].name});
                        ans.push_back({"CHAT_CONTENT", it->content});
                        num++;
                        auto temp = ++it;
                        --it;
                        messagesPool.erase(it);
                        it = temp;
                    }
                }
                char number[10];
                sprintf(number,"%d", num);
                ans.insert(ans.begin(), {"NUMBER", number});
                ans.insert(ans.begin(), {"GETCHAT", "RETURN"});
            }
            break;
        }
    }
    return msgToStr(ans);
}

Messages Server::strToMsg(char *msg) {
    Messages args;
    int length = strlen(msg);
    for (int i = 0; i < length; i++) {
        if (msg[i++] != '\\') break;
        std::string name;
        std::string content;
        while (msg[i] != 2) {
            name.push_back(msg[i++]);
        }
        i++;
        while (msg[i] != 3) {
            content.push_back(msg[i++]);
        }
        args.push_back(std::pair<std::string, std::string>(name, content));
    }
    return args;
}

std::string Server::msgToStr(Messages args) {
    std::string ans;
    for(auto it: args) {
        ans.push_back('\\');
        ans.append(it.first);
        ans.push_back(2);
        ans.append(it.second);
        ans.push_back(3);
    }
    return ans;
}