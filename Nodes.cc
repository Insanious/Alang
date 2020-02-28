#include "Nodes.h"
#include "globals.h"


void log_assignments(std::string message)
{
	if (debug_assignments)
		std::cout << "-ASSIGNMENT-\t\t\t\t\t\t\t\t " + message + '\n';
}

void log_calls(std::string message)
{
	if (debug_calls)
		std::cout << "CALL:\t\t " + message + '\n';
}

void log_evaluations(std::string message)
{
	if (debug_evaluations)
		std::cout << "EVALUATION:\t " + message + '\n';
}


Node::Node()
{
	this->tag = "uninitialised";
	this->value = "uninitialised";
}

Node::Node(std::string tag, std::string value)
{
	this->tag = tag;
	this->value = value;
}

void Node::dump(int depth)
{
	for(int i = 0; i < depth; i++)
		std::cout << "--";
	std::cout << tag << ':' << value << '\n';
	for(long unsigned int i = 0; i != children.size(); i++)
		children[i]->dump(depth+1);
}

void Node::createGraphViz()
{
	std::queue<Node*> nodes;
	int id = 0;
	int parentId = -1;

	std::string graph = "digraph { \n";
	graph += createLabel(this, id++);
	nodes.push(this);

	while (nodes.size())
	{
		Node* parent = nodes.front();
		nodes.pop();
		parentId++;

		for (auto child : parent->children)
		{
			nodes.push(child);
			graph += createLabel(child, id);
			graph += createConnection(parentId, id++);
		}
	}

	graph += '}';

	std::ofstream file;
	file.open("parse.dot");
	file << graph;
	file.close();
}

std::string Node::createLabel(Node* node, int id)
{
	std::string label = '\t' + std::to_string(id) + " [label=\"" + node->tag;

	if (node->value.length())
		label += " " + node->value;

	label += "\"];\n";

	return label;
}

std::string Node::createConnection(int from, int to)
{
	return '\t' + std::to_string(from) + " -> " + std::to_string(to) + "\n";
}



Statement::Statement() {}

Statement::~Statement() {}

Statement::Statement(std::string tag, std::string value) : Node(tag, value)
{
	log_calls("Statement::Statement(std::string tag, std::string value)");
}

Statement::Statement(std::string tag, std::string value, std::vector<Statement*> statements) : Node(tag, value)
{
	for (auto statement : statements)
		this->children.push_back(statement);

	log_calls("Statement::Statement(std::string tag, std::string value, std::vector<Statement*> statements)");
}

Statement::Statement(std::string tag, std::string value, Statement* statement) : Node(tag, value)
{
	this->children.push_back(statement);

	log_calls("Statement::Statement(std::string tag, std::string value, Statement* statement)");
}

Statement::Statement(std::string tag, std::string value, Statement* left, Statement* right) : Node(tag, value)
{
	this->children.push_back(left);
	this->children.push_back(right);

	log_calls("Statement::Statement(std::string tag, std::string value, Statement* left, Statement* right)");
}

Statement* Statement::execute()
{
	return nullptr;
}

void Statement::dot(Statement* dot)
{
	this->children.push_back(dot);
}
