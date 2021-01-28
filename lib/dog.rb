class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:) 
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT);
            SQL

        DB[:conn].execute(sql)    
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs;
            SQL

        DB[:conn].execute(sql)  
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end

    def self.new_from_db(row)
        #return an array representing a dog's data. 
        # Methods like this, that return instances of the class, are known 
        # as constructors, just like .new, except that they 
        # extend the functionality of .new without overwriting initialize.
        id = row[0]
        name = row[1]
        breed = row[2]
        new_dog = Dog.new(id: id, name: name, breed: breed)
        new_dog
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
        result = DB[:conn].execute(sql, id)[0]
        Dog.new(id: result[0], name: result[1], breed: result[2])
    end

    def self.find_by_name(name)
        # This spec will first insert a dog into the database 
        # and then attempt to find it by calling the findbyname method. 
        # The expectations are that an instance of the dog class that 
        # has all the properties of a dog is returned, not primitive data.
        # Internally, what will the find_by_name method do to find a dog; 
        # which SQL statement must it run? Additionally, what method might 
        # find_by_name use internally to quickly take a row and create an 
        # instance to represent that data?
        sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
        result = DB[:conn].execute(sql, name)[0]
        Dog.new(id: result[0], name: result[1], breed: result[2])
    end

    def self.find_or_create_by(hash)
        # dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1", name, breed)[0]
        # if !dog.empty?
        #     find_new_dog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
        # else
        #     create_new_dog = self.create(name: name, breed: breed)
        # end
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1
        SQL
      
        arr = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten
        if !arr.empty? 
            dog = self.new(id: arr[0], name: arr[1], breed: arr[2])
            dog.save
        else
            dog = self.create(hash)
        end
    end

    def update
        # This spec will create and insert a dog, and afterwards, 
        # it will change the name of the dog instance and call update. 
        # The expectations are that after this operation, there is no 
        # dog left in the database with the old name. If we query the 
        # database for a dog with the new name, we should find that dog 
        # and the ID of that dog should be the same as the original, 
        # signifying this is the same dog, they just changed their name.
        # sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
        # update_dog = DB[:conn].execute(sql, self.name, self.breed, self.id)
    
        # sql = <<-SQL
        #     SELECT * FROM dogs WHERE id = ?
        # SQL

        # dog = DB[:conn].execute(sql, self.id).first

        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def save
        # To implement this, you will have to figure out a way for an 
        # instance to determine whether it has been persisted into the 
        # DB.
        # In the first test, we create an instance. Since it has never 
        # been saved before, specify that the instance will receive a 
        # method call to insert.
        # In the next test, we create an instance, save it, change its 
        # name, and then specify that a call to the save method should 
        # trigger an update.
        if !!self.id    
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?);
            SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].last_insert_row_id
        end
        self
    end

end