package com.google.crypto.tink.shaded.protobuf;

import java.util.AbstractList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;
import java.util.RandomAccess;

/* JADX INFO: loaded from: classes.dex */
public final class j0 extends AbstractList implements E, RandomAccess {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final D f3809a;

    public j0(D d5) {
        this.f3809a = d5;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.E
    public final E a() {
        return this;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.E
    public final Object b(int i4) {
        return this.f3809a.f3734b.get(i4);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.E
    public final List d() {
        return Collections.unmodifiableList(this.f3809a.f3734b);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.E
    public final void e(AbstractC0303h abstractC0303h) {
        throw new UnsupportedOperationException();
    }

    @Override // java.util.AbstractList, java.util.List
    public final Object get(int i4) {
        return (String) this.f3809a.get(i4);
    }

    @Override // java.util.AbstractList, java.util.AbstractCollection, java.util.Collection, java.lang.Iterable, java.util.List
    public final Iterator iterator() {
        i0 i0Var = new i0();
        i0Var.f3801a = this.f3809a.iterator();
        return i0Var;
    }

    @Override // java.util.AbstractList, java.util.List
    public final ListIterator listIterator(int i4) {
        h0 h0Var = new h0();
        h0Var.f3794a = this.f3809a.listIterator(i4);
        return h0Var;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final int size() {
        return this.f3809a.size();
    }
}
