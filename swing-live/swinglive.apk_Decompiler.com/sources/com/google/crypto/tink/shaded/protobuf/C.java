package com.google.crypto.tink.shaded.protobuf;

import java.io.Serializable;

/* JADX INFO: loaded from: classes.dex */
public enum C {
    VOID(Void.class, null),
    INT(Integer.class, 0),
    LONG(Long.class, 0L),
    FLOAT(Float.class, Float.valueOf(0.0f)),
    DOUBLE(Double.class, Double.valueOf(0.0d)),
    BOOLEAN(Boolean.class, Boolean.FALSE),
    STRING(String.class, ""),
    BYTE_STRING(AbstractC0303h.class, AbstractC0303h.f3791b),
    ENUM(Integer.class, null),
    MESSAGE(Object.class, null);

    C(Class cls, Serializable serializable) {
    }
}
