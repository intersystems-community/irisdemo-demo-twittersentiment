package com.intersystems.callcenter.controller;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import javax.faces.view.ViewScoped;
import javax.inject.Inject;
import javax.inject.Named;

import org.primefaces.event.SelectEvent;

import com.intersystems.callcenter.model.Ticket;
import com.intersystems.callcenter.service.CallCenterService;
import com.intersystems.callcenter.util.FacesUtil;

@Named(value = "callCenterController")
@ViewScoped
public class CallCenterController implements Serializable{

	private static final long serialVersionUID = 1L;
	
	@Inject
	private CallCenterService callCenterService;
	
	Ticket ticket = new Ticket();
	
	private List<Ticket> tickets = new ArrayList<Ticket>();
	
	public String merge() {

		try {
			ticket = callCenterService.merge(ticket);
			FacesUtil.infoMessage("Successful post", "Post saved successfully");
		} catch (Exception e) {
			ticket = new Ticket();
			FacesUtil.errorMessage("Unsuccessful ticket", "Error details: " + e.getMessage());
		}

		return null;
	}

	public String reset() {

		ticket = new Ticket();

		return null;
	}

	public String delete() {

		try {
			callCenterService.remove(ticket.getId());
			ticket = new Ticket();
			getTicketList();
			FacesUtil.infoMessage("Successful deletion", "Ticket deleted successfully");
		} catch (Exception e) {
			ticket = new Ticket();
			FacesUtil.errorMessage("Unsuccessful deletion", "Error details: " + e.getMessage());
		}

		return null;
	}
	
	public String list() {

		try {
			getTicketList(ticket);
		} catch (Exception e) {
			ticket = new Ticket();
			FacesUtil.errorMessage("Unsuccessful query", "Error details: " + e.getMessage());
		}

		return null;

	}
	
	private void getTicketList(Ticket ticket) {
		tickets.clear();
		tickets.addAll(callCenterService.getTicketList(ticket));
	}


	public Ticket getTicket() {
		return ticket;
	}

	public void setTicket(Ticket ticket) {
		this.ticket = ticket;
	}

	public List<Ticket> getTicketList() {
		return callCenterService.getTicketList();
	}

	public void onRowSelect(SelectEvent event) {
		ticket = callCenterService.load(((Ticket) event.getObject()).getId());
	}

		
		
}
