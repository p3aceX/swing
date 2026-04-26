package com.google.crypto.tink.shaded.protobuf;

import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class i0 implements Iterator {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Iterator f3801a;

    @Override // java.util.Iterator
    public final boolean hasNext() {
        return this.f3801a.hasNext();
    }

    @Override // java.util.Iterator
    public final Object next() {
        return (String) this.f3801a.next();
    }

    @Override // java.util.Iterator
    public final void remove() {
        throw new UnsupportedOperationException();
    }
}
