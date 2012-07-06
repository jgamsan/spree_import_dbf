require 'csv'
require 'active_support'
require 'action_controller'
include ActionDispatch::TestProcess
require 'yaml'
require 'dbf'

class UpdateProductsRodamoto
  def initialize()
    @articulos_new = DBF::Table.new("/home/jose/Documentos/rodamoto/articulo.dbf")

  end

  def run

  end
end