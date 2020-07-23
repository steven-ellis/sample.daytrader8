package com.ibm.websphere.samples.daytrader.entities;

import java.io.Serializable;
import java.util.UUID;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.TableGenerator;

import com.ibm.websphere.samples.daytrader.events.ExportedEvent;

@Entity(name = "outboxevent")
@Table(name = "outboxevent")
public class OutboxEventBean implements Serializable {

    private static final long serialVersionUID = 9198643360302722475L;

    @Id
    @TableGenerator(name = "outboxeventIdGen", table = "KEYGENEJB", pkColumnName = "KEYNAME", valueColumnName = "KEYVAL", pkColumnValue = "outboxevent", allocationSize = 1000)
    @GeneratedValue(strategy = GenerationType.TABLE, generator = "outboxeventIdGen")
    @Column(name = "ID", nullable = false)
    private String id;

    @Column(name = "AGGREGATEID", nullable = false)
    private String aggregateId;

    @Column(name = "AGGREGATETYPE", nullable = false)
    private String aggregateType;

    @Column(name = "TYPE", nullable = false)
    private String type;

    @Column(name = "PAYLOAD", nullable = false)
    private String payload;

    public OutboxEventBean(){
        this.id = UUID.randomUUID().toString();
    }

    public OutboxEventBean(ExportedEvent exportedEvent) {
        this.id = UUID.randomUUID().toString();
        this.aggregateId = exportedEvent.getAggregateId();
        this.aggregateType = exportedEvent.getAggregateType();
        this.type = exportedEvent.getType();
        this.payload = exportedEvent.getPayload().toString();
    }

    public String getAggregateType() {
        return aggregateType;
    }

    public String getAggregateId() {
        return aggregateId;
    }

    public void setAggregateId(String aggregateId) {
        this.aggregateId = aggregateId;
    }

    public String getPayload() {
        return payload;
    }

    public void setPayload(String payload) {
        this.payload = payload;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public void setAggregateType(String aggregateType) {
        this.aggregateType = aggregateType;
    }
    
}