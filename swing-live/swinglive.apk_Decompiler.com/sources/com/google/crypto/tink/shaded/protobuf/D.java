package com.google.crypto.tink.shaded.protobuf;

import a.AbstractC0184a;
import java.nio.charset.Charset;
import java.util.AbstractList;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.RandomAccess;

/* JADX INFO: loaded from: classes.dex */
public final class D extends AbstractC0297b implements E, RandomAccess {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final ArrayList f3734b;

    static {
        new D(10).f3772a = false;
    }

    public D(int i4) {
        this(new ArrayList(i4));
    }

    @Override // com.google.crypto.tink.shaded.protobuf.E
    public final E a() {
        return this.f3772a ? new j0(this) : this;
    }

    @Override // java.util.AbstractList, java.util.List
    public final void add(int i4, Object obj) {
        f();
        this.f3734b.add(i4, (String) obj);
        ((AbstractList) this).modCount++;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.AbstractC0297b, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final boolean addAll(Collection collection) {
        return addAll(this.f3734b.size(), collection);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.E
    public final Object b(int i4) {
        return this.f3734b.get(i4);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.InterfaceC0319y
    public final InterfaceC0319y c(int i4) {
        ArrayList arrayList = this.f3734b;
        if (i4 < arrayList.size()) {
            throw new IllegalArgumentException();
        }
        ArrayList arrayList2 = new ArrayList(i4);
        arrayList2.addAll(arrayList);
        return new D(arrayList2);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.AbstractC0297b, java.util.AbstractList, java.util.AbstractCollection, java.util.Collection, java.util.List
    public final void clear() {
        f();
        this.f3734b.clear();
        ((AbstractList) this).modCount++;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.E
    public final List d() {
        return Collections.unmodifiableList(this.f3734b);
    }

    @Override // com.google.crypto.tink.shaded.protobuf.E
    public final void e(AbstractC0303h abstractC0303h) {
        f();
        this.f3734b.add(abstractC0303h);
        ((AbstractList) this).modCount++;
    }

    @Override // java.util.AbstractList, java.util.List
    public final Object get(int i4) {
        String str;
        ArrayList arrayList = this.f3734b;
        Object obj = arrayList.get(i4);
        if (obj instanceof String) {
            return (String) obj;
        }
        if (!(obj instanceof AbstractC0303h)) {
            byte[] bArr = (byte[]) obj;
            String str2 = new String(bArr, AbstractC0320z.f3839a);
            AbstractC0184a abstractC0184a = r0.f3834a;
            if (r0.f3834a.M(bArr, 0, bArr.length)) {
                arrayList.set(i4, str2);
            }
            return str2;
        }
        AbstractC0303h abstractC0303h = (AbstractC0303h) obj;
        abstractC0303h.getClass();
        Charset charset = AbstractC0320z.f3839a;
        if (abstractC0303h.size() == 0) {
            str = "";
        } else {
            C0302g c0302g = (C0302g) abstractC0303h;
            str = new String(c0302g.f3790d, c0302g.k(), c0302g.size(), charset);
        }
        C0302g c0302g2 = (C0302g) abstractC0303h;
        int iK = c0302g2.k();
        if (r0.f3834a.M(c0302g2.f3790d, iK, c0302g2.size() + iK)) {
            arrayList.set(i4, str);
        }
        return str;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.AbstractC0297b, java.util.AbstractList, java.util.List
    public final Object remove(int i4) {
        f();
        Object objRemove = this.f3734b.remove(i4);
        ((AbstractList) this).modCount++;
        if (objRemove instanceof String) {
            return (String) objRemove;
        }
        if (!(objRemove instanceof AbstractC0303h)) {
            return new String((byte[]) objRemove, AbstractC0320z.f3839a);
        }
        AbstractC0303h abstractC0303h = (AbstractC0303h) objRemove;
        abstractC0303h.getClass();
        Charset charset = AbstractC0320z.f3839a;
        if (abstractC0303h.size() == 0) {
            return "";
        }
        C0302g c0302g = (C0302g) abstractC0303h;
        return new String(c0302g.f3790d, c0302g.k(), c0302g.size(), charset);
    }

    @Override // java.util.AbstractList, java.util.List
    public final Object set(int i4, Object obj) {
        f();
        Object obj2 = this.f3734b.set(i4, (String) obj);
        if (obj2 instanceof String) {
            return (String) obj2;
        }
        if (!(obj2 instanceof AbstractC0303h)) {
            return new String((byte[]) obj2, AbstractC0320z.f3839a);
        }
        AbstractC0303h abstractC0303h = (AbstractC0303h) obj2;
        abstractC0303h.getClass();
        Charset charset = AbstractC0320z.f3839a;
        if (abstractC0303h.size() == 0) {
            return "";
        }
        C0302g c0302g = (C0302g) abstractC0303h;
        return new String(c0302g.f3790d, c0302g.k(), c0302g.size(), charset);
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final int size() {
        return this.f3734b.size();
    }

    public D(ArrayList arrayList) {
        this.f3734b = arrayList;
    }

    @Override // com.google.crypto.tink.shaded.protobuf.AbstractC0297b, java.util.AbstractList, java.util.List
    public final boolean addAll(int i4, Collection collection) {
        f();
        if (collection instanceof E) {
            collection = ((E) collection).d();
        }
        boolean zAddAll = this.f3734b.addAll(i4, collection);
        ((AbstractList) this).modCount++;
        return zAddAll;
    }
}
