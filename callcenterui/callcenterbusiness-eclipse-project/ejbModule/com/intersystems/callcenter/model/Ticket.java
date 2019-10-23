package com.intersystems.callcenter.model;

import java.io.Serializable;
import javax.persistence.*;
import java.util.Date;


@Entity
@Table(name="\"Ticket\"", schema="\"IRISDemo\"")
public class Ticket implements Serializable {
	
	private static final long serialVersionUID = 1L;

	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private Integer id;

	@Temporal(TemporalType.DATE)
	@Column(name="\"TicketDate\"")
	private Date ticketDate;

	@Column(name="\"TicketID\"")
	private String ticketID;

	@Column(name="\"TicketFeedback\"")
	private String ticketFeedback;

	@Column(name="\"TicketText\"")
	private String ticketText;

	@Column(name="\"TicketUser\"")
	private String ticketUser;
	
	@Column(name="\"TicketResponse\"")
	private String ticketResponse;

	public Ticket() {
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Date getTicketDate() {
		return ticketDate;
	}

	public void setTicketDate(Date ticketDate) {
		this.ticketDate = ticketDate;
	}

	public String getTicketID() {
		return ticketID;
	}

	public void setTicketID(String ticketID) {
		this.ticketID = ticketID;
	}

	public String getTicketFeedback() {
		return ticketFeedback;
	}

	public void setTicketFeedback(String ticketFeedback) {
		this.ticketFeedback = ticketFeedback;
	}

	public String getTicketText() {
		return ticketText;
	}

	public void setTicketText(String ticketText) {
		this.ticketText = ticketText;
	}

	public String getTicketUser() {
		return ticketUser;
	}

	public void setTicketUser(String ticketUser) {
		this.ticketUser = ticketUser;
	}

	public String getTicketResponse() {
		return ticketResponse;
	}

	public void setTicketResponse(String ticketResponse) {
		this.ticketResponse = ticketResponse;
	}

	
}