# -*- coding: utf-8 -*-

from openerp import models, fields, api, _, tools
from openerp.exceptions import UserError, RedirectWarning, ValidationError
import xlrd
import shutil
import logging
import openerp
_logger = logging.getLogger(__name__)

class Series_aleatoria(models.Model):
    _name = 'series_aleatorias'
    producto = fields.Char("producto")
    serie = fields.Char("No. Serie")
    qty = fields.Char("Cantidad")
    start = fields.Text("Almacen de")
    finish = fields.Text("Almacen hasta")
    stockpicking_id = fields.Integer("Stock Picking id")
class stockpickingloadseries(models.Model):
    _inherit = 'stock.picking'
    
    @api.one
    def update_series(self):

        attachment_obj = self.env['ir.attachment']
        attachments = []
        company_id = self.company_id.id
        stockpicking = self
        #fname_stockpicking = stockpicking.fname_stockpicking and stockpicking.fname_stockpicking or ''
        adjuntos = attachment_obj.search([('res_model', '=', 'stock.picking'), 
                                              ('res_id', '=', stockpicking.id)])
        #raise UserError(_("Error:Hay \n%s!") % (stockpicking.id))
        _logger.error(" archivos ajuntos" )
        ruta= "/var/lib/odoo/filestore/"
        count = 0
        for attach in adjuntos:                
          count += 1

        if count >= 2 or count == 0:
          raise UserError(_("Error:Hay \n%s archivos adjuntos, por favor adjunte el archivo o sólo deje el archivo para cargar sus series!") % (count))
        else:
          if count == 1:
            db_name = self._cr.dbname
            _logger.error("hay 1 archivo ajuntos")
            destino = ruta +db_name +"/" + adjuntos.store_fname+".xls";
            #destino = "/var/lib/odoo/.local/share/Odoo/filestore/fortuna/" + adjuntos.store_fname+".xls";
            #shutil.copy('/var/lib/odoo/.local/share/Odoo/filestore/fortuna/' + adjuntos.store_fname, destino)
            shutil.copy(ruta+db_name +'/'  + adjuntos.store_fname, destino)
            _logger.info("ARCHIVO COPIADO")
            #book = xlrd.open_workbook("/var/lib/odoo/.local/share/Odoo/filestore/fortuna/" + adjuntos.store_fname+".xls")
            book = xlrd.open_workbook(ruta+db_name +"/"  + adjuntos.store_fname+".xls")
            #serie_obj = self.pool.get('serie_tmp')
            sheet = book.sheet_by_index(0)

            nrows = sheet.nrows
            ncols = sheet.ncols
            _logger.info( nrows)
            _logger.info( ncols)
            for i in range(nrows):
                for j in range(ncols):
                    #string += '%st'%sheet.cell_value(i,j)
                    _logger.info(sheet.cell_value(i,0) )
                    _logger.info(sheet.cell_value(i,1) )
                    #if sheet.cell_value(i,4) == '':
                    #   raise UserError(_("Error:vacio columna 5 \n%s!") % ())
                    serie_obj = self.env['series_tmp']
                    self.write({'xls_file_signed_index' : adjuntos.store_fname})
                    serie_vals = {
                      'producto': sheet.cell_value(i,0),
                      'serie': sheet.cell_value(i,1),
                      'stockpicking_id': stockpicking.id,
                    }
                serie_create_id = serie_obj.create(serie_vals)
                _logger.info("Termino de guardar")
    @api.one
    def loads_series(self):
        attachment_obj = self.env['ir.attachment']
        attachments = []
        company_id = self.company_id.id
        stockpicking = self
        #fname_stockpicking = stockpicking.fname_stockpicking and stockpicking.fname_stockpicking or ''
        adjuntos = attachment_obj.search([('res_model', '=', 'stock.picking'), 
                                              ('res_id', '=', stockpicking.id)])
        #raise UserError(_("Error:Hay \n%s!") % (stockpicking.id))
        _logger.error(" archivos ajuntos" )
        ruta ="/var/lib/odoo/filestore/"
        count = 0
        for attach in adjuntos:                
          count += 1

        if count >= 2 or count == 0:
          raise UserError(_("Error:Hay \n%s archivos adjuntos, por favor adjunte el archivo o sólo deje el archivo para cargar sus series!") % (count))
        else:
          if count == 1:
            _logger.error("hay 1 archivo ajuntos")
            db_name = self._cr.dbname
            #destino = "/var/lib/odoo/filestore/pruebas/" + adjuntos.store_fname+".xls";
            #destino = "/var/lib/odoo/.local/share/Odoo/filestore/"+db_name +"/"  + adjuntos.store_fname+".xls";
            destino = ruta+db_name +"/"  + adjuntos.store_fname+".xls";
            shutil.copy(ruta+db_name +"/"  + adjuntos.store_fname, destino)
            #shutil.copy('/var/lib/odoo/filestore/pruebas/' + adjuntos.store_fname, destino)
            _logger.info("ARCHIVO COPIADO")
            book = xlrd.open_workbook(ruta+db_name +"/"  + adjuntos.store_fname+".xls")
            #book = xlrd.open_workbook("/var/lib/odoo/filestore/pruebas/" + adjuntos.store_fname+".xls")
            #serie_obj = self.pool.get('serie_tmp')
            sheet = book.sheet_by_index(0)

            nrows = sheet.nrows
            ncols = sheet.ncols
            _logger.info( nrows)
            _logger.info( ncols)


            #self.env['mail.message'].sudo(self._uid).create({'model': 'stock.picking', 'res_id': self.partner_id.id, 'body': 'Test'})
            for i in range(nrows):
                for j in range(ncols):
                    #string += '%st'%sheet.cell_value(i,j)
                    _logger.info(sheet.cell_value(i,0) )
                    _logger.info(sheet.cell_value(i,1) )
                    #if sheet.cell_value(i,4) == '':
                    #   raise UserError(_("Error:vacio columna 5 \n%s!") % ())
                    serie_obj = self.env['load_series']
                    self.write({'xls_file_signed_index' : adjuntos.store_fname})
                    serie_vals = {
                      'producto': sheet.cell_value(i,0),
                      'serie': sheet.cell_value(i,1),
                      'stockpicking_id': stockpicking.id,
                    }
                serie_create_id = serie_obj.create(serie_vals)
                _logger.info("Termino de guardar")

    @api.one
    def series_aleatoria(self):
        attachment_obj = self.env['ir.attachment']
        attachments = []
        company_id = self.company_id.id
        stockpicking = self

        _logger.error("Entro a cargar aleatoriamente")

        serie_obj = self.env['series_aleatorias']
        serie_vals = {
            'stockpicking_id': stockpicking.id,
        }
        serie_create_id = serie_obj.create(serie_vals)
        _logger.info("Termino de guardar")

class load_series_temp(models.Model):

    _name = 'series_tmp'
    producto = fields.Char("producto")
    serie= fields.Char("No. Serie")
    qty = fields.Char("Cantidad")
    start = fields.Text("Almacen de")
    finish = fields.Text("Almacen hasta")
    stockpicking_id = fields.Integer("Stock Picking id")
class loadstockproduction(models.Model):
  
  _inherit = 'stock.production.lot'
  load = fields.Boolean(string="Cargado",default=True)
class lo_load_series(models.Model):

    _name = 'load_series'
    producto = fields.Char("producto")
    serie= fields.Char("No. Serie")
    qty = fields.Char("Cantidad")
    start = fields.Text("Almacen de")
    finish = fields.Text("Almacen hasta")
    stockpicking_id = fields.Integer("Stock Picking id")
