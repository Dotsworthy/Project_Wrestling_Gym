require_relative( '../db/sql_runner' )

class Trainer

  attr_reader :id, :first_name, :last_name, :user_name, :image_url


  def initialize(options)
    @id = options['id'].to_i if options['id']
    @first_name = options['first_name']
    @last_name = options['last_name']
    @user_name = options['user_name']
    @image_url = options['image_url']
  end

  def save()
    sql = "INSERT INTO trainers
      (
      first_name,
      last_name,
      user_name,
      image_url
      )
      VALUES
      (
        $1, $2, $3, $4
      )
      RETURNING id"
    values = [@first_name, @last_name, @user_name, @image_url]
    results = SqlRunner.run(sql, values)
    @id = results.first()['id'].to_i
  end

  def update()
    sql = "
      UPDATE trainers SET (
      first_name,
      last_name,
      user_name,
      image_url
      )
      = (
      $1, $2, $3, $4
      )
      WHERE id = $5"
    values = [@first_name, @last_name, @user_name, @image_url, @id]
    SqlRunner.run(sql,values)
  end

  def pretty_name()
    return "#{@first_name} #{@last_name}"
  end

  def image_change(image)
    @image_url = image
  end

  def self.all()
    sql = "SELECT * FROM trainers"
    results = SqlRunner.run(sql)
    return results.map { |trainer| Trainer.new(trainer) }
  end

  def self.find(id)
    sql = "SELECT * FROM trainers WHERE id = $1"
    values = [id]
    result = SqlRunner.run(sql, values)
    return Trainer.new(result.first)
  end

  def self.delete(id)
    sql = "DELETE FROM trainers WHERE id = $1"
    values = [id]
    SqlRunner.run(sql, values)
  end

  def self.delete_all()
    sql = "DELETE FROM trainers"
    SqlRunner.run( sql )
  end
end

def Trainer.search(string)
  sql = "Select * FROM trainers WHERE LOWER(first_name) LIKE $1 OR LOWER(last_name) LIKE $1 OR LOWER(user_name) LIKE $1"
  values = ["%#{string.downcase}%"]
  search = SqlRunner.run(sql, values)
  return result = search.map { |trainer| Trainer.new(trainer) }
end
