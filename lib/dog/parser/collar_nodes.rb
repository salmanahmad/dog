#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Treetop::Runtime::SyntaxNode
    
    def to_collar
      to_hash
    end
    
    def self.from_collar(collar)
      self.from_hash(collar)
    end
    
    def to_hash
      hash = {}
      hash[:offset] = self.interval.first
      hash[:text_value] = self.text_value
      hash[:name] = self.class.name
      
      hash[:input] = self.input
      hash[:interval] = self.interval
      
      unless self.elements.nil?
        hash[:elements] = self.elements.map do |element|
          element.to_hash
        end
      else
        hash[:elements] = nil
      end
      
      return hash
    end
    
    def self.from_hash(hash)
      offset = hash[:offset]
      text_value = hash[:text_value]
      name = hash[:name]
      
      input = hash[:input]
      interval = hash[:interval]
      
      elements = hash[:elements]
      elements.map! do |element|
        element = self.from_hash(element)
      end
      
      node_type = Object::const_get(name)
      node = node_type.new(input, interval, elements)
      
      return node
    end
    
  end
  
  module CompileChild
    def compile(buffer)
      if self.elements.size == 1 then
        self.elements.first.compile
      elsif self.elements.size == 0
        return nil
      else
        raise "#{self.class.name} has more than 1 child."
      end
    end
  end
  
  module CompileChildAsText
    def compile(buffer)
      if self.elements.size == 1 then
        self.elements.first.text_value
      elsif self.elements.size == 0
        return nil
      else
        raise "#{self.class.name} has more than 1 child."
      end
    end
  end
  
  
  ####### These are not needed anymore now that I am transpiling
  
  module CompileOperationState
    def compile
      state = OperationState.new
      state.operation = self
      return state
    end
  end
  
  module RunChild
    def run
      if self.elements.size == 1 then
        return self.elements.first.run
      elsif self.elements.size == 0
        return nil
      else
        raise "#{self.class.name} has more than 1 child."
      end
    end
  end
  
  module NotRunnable
    def run
      raise "Attempting to run an unrunnable node: #{self.class.name}."
    end
  end
  
  ###################################
  
  
  class CollarNode< Treetop::Runtime::SyntaxNode
    # TODO - Remove these???
    #include NotRunnable
    #include CompileOperationState
    # TODO - this default is somewhat problematic. For example, for clauses or predicates
  end
  
  class Program < CollarNode
    def compile
      program = FormattedString.new
      self.elements.each do |node|
        program << node.compile
      end
      
      # TODO - Implement this...
      CompilationContext.program_section << program
    end
  end
  
  class ProgramStatements < CollarNode
    include CompileChild
  end
  
  class Statements < CollarNode
    def compile
      states = []
      
      code = FormattedString.new
      
      self.elements.each do |node|
        code << node.compile
      end
      
      return code.string
    end
  end
  
  class TopLevelStatement < CollarNode
    include CompileChild
    # TODO - I have to do something here. With newlines, or, something
  end
  
  class Statement < CollarNode
    include CompileChild
    # TODO - I have to do something here
  end
  
  class Primary < CollarNode
    include CompileChild
    # TODO - I have to do something here...for parenthesis
  end
  
  class Access < CollarNode
    def compile
      if elements[1] then
        # TODO - Error message if the identifier is not an array or a hash
        return "(#{elements[0].compile})#{elements[1].compile}"
      else
        return elements[0].compile
      end
    end
  end
  
  class AccessBracket < CollarNode
    def compile
      # TODO - I have to create the path if the object does not already have it
      path = "[#{elements[0].compile}]"
      path += "#{elements[1].compile}" if elements[1]
      return path
    end
  end
  
  class AccessDot < CollarNode
    def compile
      # TODO - I have to create the path if the object does not already have it
      path = "[#{elements[0].text_value}]"
      path += "#{elements[1].compile}" if elements[1]
      return path
    end
  end
  
  class AccessPossessive < CollarNode
    def compile
      %s|raise "#{self.class} not implemented."|
    end
  end
  
  class Assignment < CollarNode
    def compile
      lhs = elements[0].compile
      rhs = elements[2].compile
      
      variable = nil
      if elements[0].class == Access 
        variable = elements[0].elements[0].text_value
      elsif elements[0].class == Identifier
        variable = elements[0].text_value
      end
      
      # TODO - I have to implement how Server.register works...
      # TODO - I have to implement Variable#has_changed
      code = ""
      code += "#{lhs} = #{rhs}\n"
      code += "Variable.named(#{variable}).has_changed\n"
      code += "Server.register(#{lhs})\n" if elements[2].class == Ask
      return code
    end
  end
  
  class Operation < CollarNode
    def compile
      if elements[0].class == NotOperator then
        "(#{elements[0].compile}(#{elements[1].compile}))"
      else
        "((#{elements[0].compile}) #{elements[1].compile} (#{elements[2].compile}))"
      end
    end
  end
  
  class Identifier < CollarNode
    def compile
      "Variable.named(#{self.text_value}).value"
    end
  end
  
  class AssignmentOperator < CollarNode
    def compile
      "="
    end
  end
  
  class AdditionOperator < CollarNode
    def compile
      "+"
    end
  end
  
  class SubtractionOperator < CollarNode
    def compile
      "-"
    end
  end
  
  class MultiplicationOperator < CollarNode
    def compile
      "*"
    end
  end
  
  class DivisionOperator < CollarNode
    def compile
      "/"
    end
  end
  
  class EqualityOperator < CollarNode
    def compile
      "=="
    end
  end
  
  class InequalityOperator < CollarNode
    def compile
      "!="
    end
  end
  
  class GreaterThanOperator < CollarNode
    def compile
      ">"
    end
  end
  
  class LessThanOperator < CollarNode
    def compile
      "<"
    end
  end
  
  class GreaterThanEqualOperator < CollarNode
    def compile
      ">="
    end
  end
  
  class LessThanEqualOperator < CollarNode
    def compile
      "<="
    end
  end
  
  class AndOperator < CollarNode
    def compile
      "&&"
    end
  end
  
  class OrOperator < CollarNode
    def compile
      "||"
    end
  end
  
  class NotOperator < CollarNode
    def compile
      "!"
    end
  end
  
  class UnionOperator < CollarNode
    def compile
      # TODO
    end
  end
  
  class IntersectOperator < CollarNode
    def compile
      # TODO
    end
  end
  
  class DifferenceOperator < CollarNode
    def compile
      # TODO
    end
  end
  
  class AppendOperator < CollarNode
    def compile
      # TODO
    end
  end
  
  class PrependOperator < CollarNode
    def compile
      # TODO
    end
  end
  
  class AssociatesOperator < CollarNode
    def compile
      # TODO
    end
  end
  
  class ContainsOperator < CollarNode
    def compile
      # TODO
    end
    
    #def run(arg1, arg2)
    #  arg1.include? arg2
    #end
  end
  
  
  
  
  class StructureDefinition < CollarNode
    def compile
      
    end
  end
  
  class StructureProperties < CollarNode
  
  end
  
  class StructureProperty < CollarNode
    def compile
      
    end
  end
  
  class StructurePropertyType < CollarNode
    def compile
      
    end
  end
  
  class StructurePropertyName < CollarNode
    def compile
      
    end
  end
  
  class StructurePropertyRelationship < CollarNode
    
  end
  
  class StructurePropertyRelationshipInverse < CollarNode
    
  end
  
  class StructurePropertyRelationshipPath < CollarNode
    
  end
  
  
  class StructurePropertyDirection < CollarNode
    def compile
      
    end
  end
  
  class StructurePropertyDirectionInput < CollarNode
    def compile
      
    end
  end
  
  class StructurePropertyDirectionOutput < CollarNode
    def compile
      
    end
  end
  
  
  
  
  
  
  
  
  
  
  class Listen < CollarNode
    def compile
      
      configuration = {}
      for element in elements do
        configuration[element.class] = element.compile
      end
      
      if configuration[ViaClause] then
        
        case configuration[ViaClause]
        when "http"
          path = configuration[ListenAtClause] || ("/" + configuration[ListenForClause])
          variable_name = configuration[ListenForClause]
          people = configuration[ListenToClause]
          
          # TODO - implement this. See comment block below...
          listen = "listen(:to => #{people}, :at => #{path}, :for => #{variable_name})"
          CompilationContext.server_section << listen << "\n"
        else
          raise "Unknown via command."
        end
      end
      
      # Listen returns nothing in the current context
      return ""
    end
    
    #if Variable.exists?(variable_name) then
    #  raise "Listening on a variable, #{variable_name}, that already exists."
    #end
    
    #variable = ListenVariable.named(variable_name)
    
    #Server.listeners = true
    #Server.aget path do
    #  
    #  # TODO Handle authentication here...
    #  if to.class != Public && !session['dormouse_access_token'] then
    #    $authenticate_redirects ||= {}
    #    $authenticate_redirects[session[:session_id]] = path
    #    redirect Environment.dormouse_new_session_url
    #  else
    #    variable.push_value(params)
    #    context = RequestContext.new
    #    variable.notify_dependencies context
    #    
    #    EM.next_tick do
    #      body context.body
    #    end
    #  end
    # 
    #end
    
  end 
  
  class ListenToClause < CollarNode
    include CompileChild
  end
  
  class ListenAtClause < CollarNode
    include CompileChild
  end
  
  class ListenForClause < CollarNode
    include CompileChildAsText
  end
  
  class Allow < CollarNode
    
  end
  
  class AllowModifier < CollarNode
    
  end
  
  class AllowProfile < CollarNode
    
  end
  
  class Ask < CollarNode
    def compile
      
    end
    
    def run
      configuration = {}
      for element in elements do
        configuration[element.class] = element.run
      end
      
      via = configuration[ViaClause]
      content = configuration[AskToClause]
      using = configuration[UsingClause]
      using ||= {}
      
      callback_path = UUID.new.generate
      
      case via
      when "http_response"
        
        if content.class == TaskVariable then
          content = content.render(using, {'DogAction' => callback_path})
        end
        
        Fiber.current.request_context.body = content
      else
        raise "Unknown via command in ask."
      end
      
      return callback_path
    end
  end
  
  class AskToClause < CollarNode
    include RunChild
  end
  
  class Notify < CollarNode
    def run
      configuration = {}
      for element in elements do
        configuration[element.class] = element.run
      end
      
      via = configuration[ViaClause]
      content = configuration[NotifyOfClause]
      using = configuration[UsingClause]
      using ||= {}
      
      case via
      when "http_response"
        
        if content.class == MessageVariable then
          content = content.render(using)
        end
        
        Fiber.current.request_context.body = content
      else
        raise "Unknown via command in notify."
      end
      
    end
  end
  
  class NotifyOfClause < CollarNode
    include CompileChild
  end
  
  class Reply < CollarNode
    def compile
      
    end
  end
  
  class ReplyWithClause < CollarNode
    def compile
      
    end
  end
  
  class ReplyDisallow < CollarNode
    def compile
      raise "Compilation error: REPLY can only exist inside of an ON block."
    end
  end
  
  
  
  
  class Compute < CollarNode
    def compile
      # TODO
    end
  end
  
  class UsingClause < CollarNode
    include CompileChild
  end
  
  class OnClause < CollarNode
    def run
      
    end
  end
  
  class OnClauseItems < CollarNode
    def run
      
    end
  end
  
  class OnClauseItem < CollarNode
    def run
      
    end
  end
  
  class ViaClause < CollarNode
    include CompileChildAsText
  end
  
  class InClause < CollarNode
    include CompileChild
  end
  
  class InClauseIdentifiers < CollarNode
    def compile
      identifiers = []
      identifiers << elements[0].text_value
      identifiers << elements[1].text_value if elements[1]
      return identifiers
    end
  end
  
  class IdentifierAssociations < CollarNode
    def run
      hash = {}
      for element in elements do
        hash.merge! element.run
      end
      
      return hash
    end
  end
  
  class IdentifierAssociation < CollarNode
    def run
      hash = {}
      hash[elements[0].text_value] = elements[1].run
      return hash
    end
  end
  
  class Me < CollarNode
    def compile
      "(People.me)"
    end
  end
  
  class Public < CollarNode
    def compile
      "(People.public)"
    end
  end
  
  class Person < CollarNode
    def run
      from = elements[0].compile
      
      where = nil
      where = elements[1].compile if elements[1]
      
      return "People.find_one(:from => #{from}, :where => #{where})"
    end
  end
  
  class People < CollarNode
    def run
      from = elements[0].compile
      
      where = nil
      where = elements[1].compile if elements[1]
      
      return "People.find_all(:from => #{from}, :where => #{where})"
    end
  end
  
  class PeopleFromClause < CollarNode
    include CompileChildAsText
  end
  
  class PeopleWhereClause < CollarNode
    include CompileChild
  end
  
  class KeyPaths < CollarNode
    def compile
      paths = []
      for element in elements do
        paths << element.run
      end
      paths
      
      return "[#{paths.join(",")}]"
    end
  end
  
  class KeyPath < CollarNode
    include CompileChildAsText
  end
  
  class Predicate < CollarNode
    include CompileChild
  end
  
  class PredicateBinary < CollarNode
    def compile
      "[#{elements[0].compile}, #{elements[1].text_value}, #{elements[2].compile}]"
    end
  end
  
  class PredicateUnary < CollarNode
    def run
      "[#{elements[0].text_value}, #{elements[1].compile}]"
    end
  end
  
  class PredicateConditonal < CollarNode
    def run
      "[#{elements[0].compile}, #{elements[1].text_value}, #{elements[2].compile}]"
    end
  end
  
  class Config < CollarNode
    def run
      "Config.set(#{elements[0].text_value}, #{elements[1].compile})"
    end
  end
  
  class Import < CollarNode
    def compile
      #elements[0].run(elements[1].run, elements[2])
      "Import.#{elements[0].compile}(#{elements[1].compile}, #{elements[2].compile})"
    end
  end
  
  class ImportAsClause < CollarNode
    include CompileChildAsText
  end
  
  class ImportFunction < CollarNode
    def compile
      "function"
    end
  end
  
  class ImportData < CollarNode
    def compile
      "data"
    end
  end
  
  class ImportCommunity < CollarNode
    def compile
      "community"
    end
  end
  
  class ImportTask < CollarNode
    def compile
      "task"
    end
    
    def run(path, variable = nil)
      # TODO - This code is redundant with ImportMessage
      if variable then
        variable = variable.run
      else
        variable = File.basename(path, ".task")
        variable.gsub!('.', '_')
      end
      
      variable = TaskVariable.named(variable)
      variable.value = File.absolute_path(path, Environment.program_directory)
    end
  end
  
  class ImportMessage < CollarNode
    def compile
      "message"
    end
    
    def run(path, variable = nil)
      # TODO - This code is redundant with ImportTask
      if variable then
        variable = variable.run
      else
        variable = File.basename(path, ".message")
        variable.gsub!('.', '_')
      end
      
      variable = MessageVariable.named(variable)
      variable.value = File.absolute_path(path, Environment.program_directory)
    end
  end
  
  class ImportConfig < CollarNode
    def compile
      "config"
    end
  end
  
  ### Function stuff start
  
  class Function < CollarNode
  end
  
  class FunctionParameters < CollarNode
  end
  
  class FunctionParameter < CollarNode
  end
  
  class FunctionOn < CollarNode
  end
  
  class FunctionUsing < CollarNode
  end
  
  class FunctionOptionalParameters < CollarNode
  end
  
  class FunctionOptionalParameter < CollarNode
  end
  
  ### Function stuff stop
  
  class On < CollarNode
    def compile
      state = nil
      
      if elements[1] then
        state = OnState.new
        state.dependency = elements[0].compile
        state.add_child(elements[1].compile)
      end
      
      return state
    end
  end
  
  class If < CollarNode
    def compile
      state = nil
      
      if elements[0] then
        condition = elements[0]
        
        if elements[1] then
          element = elements[1]
          
          true_branch = ConditionState.new
          true_branch.condition = condition
          true_branch.add_child(element.compile)
          
          state = IfState.new
          state.add_child(true_branch)
        end
        
        if elements[2] then
          element = elements[2]
          
          false_branch = ConditionState.new
          false_branch.add_child(element.compile)
          
          state.add_child(false_branch)
        end
        
      end
      
      return state
    end
  end
  
  class ElseClause < CollarNode
    include CompileChild
  end
  
  class For < CollarNode
    def compile
      state = nil
      
      if elements[1] then
        state = ForState.new
        state.enumerable = elements[0]
        state.add_child(element[1].compile)
      end
      
      return state
    end
  end
  
  class Repeat < CollarNode
    def compile
      state = nil
      
      if elements[1] then
        state = RepeatState.new
        state.count = elements[0]
        state.add_child(element[1].compile)
      end
      
      return state
    end
  end
  
  class Break < CollarNode
    def compile
      "break;"
    end
  end
  
  class Print < CollarNode
    def compile
      "puts(#{elements.first.compile})"
    end
  end
  
  class Inspect < CollarNode
    def compile
      "puts((#{elements.first.compile}).inspect)"
    end
  end
  
  class ArrayLiteral < CollarNode
    def compile
      items = self.elements.first
      if items then
        return items.compile
      else
        return "[]"
      end
    end
  end
  
  class ArrayItems < CollarNode
    def compile
      items = []
      for element in self.elements do
        items << element.compile
      end
      
      return "[#{items.join(",")}]"
    end
  end
  
  class ArrayItem < CollarNode
    include CompileChild
  end
  
  class HashLiteral < CollarNode
    def compile
      associations = self.elements.first
      if associations then
        return associations.compile
      else
        return "{}"
      end
    end
  end
  
  class HashAssociations < CollarNode
    def compile
      compiled_associations = []
      for element in self.elements do
        compiled_associations = element.compile
      end
      
      return "{#{compiled_associations.join(",")}}"
    end
  end
  
  class HashAssociation < CollarNode
    def compile
      "#{self.elements[0].compile} => #{self.elements[1].compile}"
    end
  end
  
  class StringLiteral < CollarNode
    def compile
      self.text_value
    end
  end
  
  class IntegerLiteral < CollarNode
    def compile(buffer)
      self.text_value
    end
  end
  
  class FloatLiteral < CollarNode
    def compile
      self.text_value
    end
  end
  
  class TrueLiteral < CollarNode
    def compile
      "true"
    end
  end
  
  class FalseLiteral < CollarNode
    def compile
      "false"
    end
  end
  
end