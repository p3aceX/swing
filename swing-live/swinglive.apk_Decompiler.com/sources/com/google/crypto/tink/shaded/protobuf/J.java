package com.google.crypto.tink.shaded.protobuf;

/* JADX INFO: loaded from: classes.dex */
public final class J implements O {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public O[] f3738a;

    @Override // com.google.crypto.tink.shaded.protobuf.O
    public final boolean a(Class cls) {
        for (O o4 : this.f3738a) {
            if (o4.a(cls)) {
                return true;
            }
        }
        return false;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.O
    public final b0 b(Class cls) {
        for (O o4 : this.f3738a) {
            if (o4.a(cls)) {
                return o4.b(cls);
            }
        }
        throw new UnsupportedOperationException("No factory is available for message type: ".concat(cls.getName()));
    }
}
