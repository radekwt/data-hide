#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>
using namespace std;
size_t split(const std::string &txt, std::vector<std::string> &strs, char ch){
    size_t pos = txt.find(ch);
    size_t initialPos = 0;
    strs.clear();

    while(pos != std::string::npos){
        strs.push_back(txt.substr(initialPos,pos-initialPos));
        initialPos = pos+1;
        pos = txt.find(ch,initialPos);
    }

    strs.push_back(txt.substr(initialPos,std::min(pos,txt.size()) - initialPos+1));
    return strs.size();
}
int main(){
    std::ifstream inputFile("istatFile");
    if(!inputFile.is_open()){
        std::cerr << "Unable to open file."<<std::endl;
    }
    std::string searchName = "size:";
    std::string line;

    while(std::getline(inputFile, line)){
        if(line.find(searchName) != std::string::npos){
            std::cout<<line<<std::endl;
            break;
        }
    }
    std::vector<std::string> strs;
    split(line,strs,' ');
    
    std::istringstream iss(strs[1]);
    int fileSize = -1;
    if(iss>>fileSize){
        cout<<fileSize<<endl;
    }
    inputFile.close();
    return fileSize;
}