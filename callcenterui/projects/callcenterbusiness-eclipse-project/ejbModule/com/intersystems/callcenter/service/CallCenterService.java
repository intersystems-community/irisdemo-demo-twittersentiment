package com.intersystems.callcenter.service;

import java.io.Serializable;
import java.util.List;

import javax.ejb.LocalBean;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.TypedQuery;

import com.intersystems.callcenter.model.Ticket;


@Stateless
@LocalBean
public class CallCenterService implements Serializable {

	private static final long serialVersionUID = 1L;

	@PersistenceContext(unitName="callcenterbusiness")
	private EntityManager em;

	public CallCenterService() {
		super();
	}

	public Ticket merge(Ticket t) {
		return em.merge(t);
	}

	public void remove(Integer id) {
		em.remove(em.find(Ticket.class, id));
	}

	public Ticket load(Integer id) {
		return em.find(Ticket.class, id);
	}

	public List<Ticket> getTicketList() {
		return em.createQuery("SELECT t FROM Ticket t", Ticket.class).getResultList();
	}

	public List<Ticket> getTicketList(Ticket ticket) {

		String qry = "SELECT t FROM Ticket t WHERE 1 = 1";

		if (ticket != null && ticket.getTicketText() != null && !ticket.getTicketText().isEmpty()) {
			qry = qry + " AND UPPER(t.ticketText) LIKE :ticketText";
		}

		TypedQuery<Ticket> qryTicket = em.createQuery(qry, Ticket.class);

		if (ticket != null && ticket.getTicketText() != null && !ticket.getTicketText().isEmpty()) {
			qryTicket.setParameter("ticketText", "%" + ticket.getTicketText().toUpperCase() + "%");
		}

		return qryTicket.getResultList();
	}

}