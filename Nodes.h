#ifndef NODES_H
#define NODES_H

#include <string>
#include <vector>
#include <iostream>
#include <queue>
#include <fstream>
#include <cmath>

class Node
{
public:
	std::string tag, value;
	std::vector<Node*> children;
	Node(std::string t, std::string v);
	Node();

	void dump(int depth=0);
	void createGraphViz();
	std::string createLabel(Node* node, int id);
	std::string createConnection(int from, int to);

};



class Statement : public Node
{
public:
	//enum Type { VARIABLE, STRING, INTEGER, FLOAT, BOOLEAN, PARENTHESIS, BINARYOPERATION, IO_READ, LIST, LENGTH, FUNCTIONCALL } type;

	Statement();
	Statement(std::string tag, std::string value);
	Statement(std::string tag, std::string value, std::vector<Statement*> statements);
	Statement(std::string tag, std::string value, Statement* statement);
	Statement(std::string tag, std::string value, Statement* left, Statement* right);
	~Statement();

	Statement* execute();

	void dot(Statement* dot);

};






#endif
