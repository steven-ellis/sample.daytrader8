package com.ibm.websphere.samples.daytrader.events;

import java.time.Instant;

import com.fasterxml.jackson.databind.JsonNode;

public interface ExportedEvent {

    /**
     * The id of the aggregate affected by a given event.  For example, the order id in case of events
     * relating to an order, or order lines of that order.  This is used to ensure ordering of events
     * within an aggregate type.
     */
    String getAggregateId();

    /**
     * The type of the aggregate affected by the event.  For example, "Order" in case of events relating
     * to an order, or order lines of that order.  This is used as the topic name.
     */
    String getAggregateType();

    /**
     * The type of an event.  For example, "OrderCreated" or "OrderLineCancelled" for events that
     * belong to an given aggregate type such as "Order".
     */
    String getType();

    /**
     * The timestamp at which the event occurred.
     */
    Instant getTimestamp();

    /**
     * The event payload.
     */
    JsonNode getPayload();
}