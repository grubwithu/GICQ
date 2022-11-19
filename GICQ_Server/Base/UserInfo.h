//
// Created by Grub on 2022/11/14.
//

#ifndef GICQ_SERVER_USERINFO_H
#define GICQ_SERVER_USERINFO_H

#include <string>


class UserInfo {
public:
    std::string name;
    std::string id;
    std::string pwd;
    std::string registerDate;
    UserInfo(){}
    UserInfo(const std::string &name,
             const std::string &id,
             const std::string &pwd,
             const std::string &registerDate)
            : name(name), id(id), pwd(pwd), registerDate(registerDate) {}
};


#endif //GICQ_SERVER_USERINFO_H
