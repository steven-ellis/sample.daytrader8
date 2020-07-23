package com.ibm.websphere.samples.daytrader.events;

import java.time.Instant;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.ibm.websphere.samples.daytrader.entities.OrderDataBean;

public class OrderCreatedEvent implements ExportedEvent {

    private static ObjectMapper mapper = new ObjectMapper();

    private final long id;
    private final JsonNode order;
    private final Instant timestamp;

    private OrderCreatedEvent(long id, JsonNode order) {
        this.id = id;
        this.order = order;
        this.timestamp = Instant.now();
    }

    public static OrderCreatedEvent of(OrderDataBean orderDataBean) {
        ObjectNode asJson = mapper.createObjectNode()
                .put("id", orderDataBean.getOrderID())
                .put("type", orderDataBean.getOrderType())
                .put("openDate", orderDataBean.getOpenDate().getTime())
                .put("symbol", orderDataBean.getQuote().getSymbol())
                .put("quantity", orderDataBean.getQuantity())
                .put("price", orderDataBean.getPrice())
                .put("orderFee",  orderDataBean.getOrderFee())
                .put("accountId",  orderDataBean.getAccount().getAccountID());

        return new OrderCreatedEvent(orderDataBean.getOrderID(), asJson);
    }

    @Override
    public String getAggregateId() {
        return String.valueOf(id);
    }

    @Override
    public String getAggregateType() {
        return "Order";
    }

    @Override
    public String getType() {
        return "OrderCreated";
    }

    @Override
    public JsonNode getPayload() {
        return order;
    }

    @Override
    public Instant getTimestamp() {
        return timestamp;
    }
}