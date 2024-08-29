#include <iostream>
#include <fstream>
#include <sys/stat.h>
#include <cmath>
#include <string>
int main(int argc, char *argv[]) {
    if (argc != 7) {
        std::cout << "Usage: " << argv[0] << " <output_file_path> <input_file_path> <partition path>\n";
        return 1;
    }
    const char* file_path = argv[1];
    std::string output_file(argv[1]);
    std::string input_file(argv[2]);
    std::string partition(argv[3]);
    std::string sec_per_cluster(argv[4]);
    std::string bytes_per_sec(argv[5]);
    std::string last_cluster_index(argv[6]);
    std::string parseFile = "temp";
    std::string command;
    struct stat fileStat;
    struct stat input_fileStat;
    if(stat(file_path,&fileStat)==0){
        std::cout<<"OUTPUT file path: "<<output_file<<std::endl;
        std::cout<<"INPUT file path: "<<input_file<<std::endl;
        std::cout<<"Physical size: "<<fileStat.st_size<<std::endl;
        std::cout<<"Logical size: "<<fileStat.st_blocks * 512<<std::endl;
        std::cout<<"Block size: "<<fileStat.st_blksize<<std::endl;
        std::cout<<"INode: "<<fileStat.st_ino<<std::endl;
    }
    if(stat(argv[2],&input_fileStat)==0){
        std::cout<<"Input file - Physical size: "<<input_fileStat.st_size<<std::endl;
    }


    int last_block = std::stoi(last_cluster_index);
    int bytes_per_sec_int = std::stoi(bytes_per_sec);
    int phys = fileStat.st_size;
    int phys_blocks_num = std::ceil(phys/float(bytes_per_sec_int));
    int sectors_to_write = fileStat.st_blocks - phys_blocks_num;
    int starting_sector = stoi(sec_per_cluster) - sectors_to_write;

    std::cout<<"Last block: "<<last_block<<std::endl;
    std::cout<<"Start sector(OFFSET): "<<starting_sector<<std::endl;
    std::cout<<"Available sectors to write: "<<sectors_to_write<<std::endl;
    int bs = bytes_per_sec_int;
    int seek = (last_block) * stoi(sec_per_cluster)+starting_sector;
    int count = sectors_to_write;
    if(sectors_to_write*std::stoi(bytes_per_sec)<input_fileStat.st_size){
        std::cerr<<"Size of a slack space in this file is too small"<<std::endl;
        return -1;
    }
    command =   "./write.sh "+
                input_file+" "+
                partition+" "+
                std::to_string(bs)+" "+
                "0"+" "+
                std::to_string(seek)+" "+
                std::to_string(count);
    std::cout<<command<<std::endl;
    int skip = bs * seek;
    system(command.c_str());
    std::cout<<"Saved: "<<input_fileStat.st_size<<" bytes";
    return 0;
}


