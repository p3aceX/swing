package n;

import java.util.Collection;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class j implements Collection {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ Y0.d f5850a;

    public j(Y0.d dVar) {
        this.f5850a = dVar;
    }

    @Override // java.util.Collection
    public final boolean add(Object obj) {
        throw new UnsupportedOperationException();
    }

    @Override // java.util.Collection
    public final boolean addAll(Collection collection) {
        throw new UnsupportedOperationException();
    }

    @Override // java.util.Collection
    public final void clear() {
        this.f5850a.a();
    }

    @Override // java.util.Collection
    public final boolean contains(Object obj) {
        return this.f5850a.f(obj) >= 0;
    }

    @Override // java.util.Collection
    public final boolean containsAll(Collection collection) {
        Iterator it = collection.iterator();
        while (it.hasNext()) {
            if (!contains(it.next())) {
                return false;
            }
        }
        return true;
    }

    @Override // java.util.Collection
    public final boolean isEmpty() {
        return this.f5850a.d() == 0;
    }

    @Override // java.util.Collection, java.lang.Iterable
    public final Iterator iterator() {
        return new g(this.f5850a, 1);
    }

    @Override // java.util.Collection
    public final boolean remove(Object obj) {
        Y0.d dVar = this.f5850a;
        int iF = dVar.f(obj);
        if (iF < 0) {
            return false;
        }
        dVar.h(iF);
        return true;
    }

    @Override // java.util.Collection
    public final boolean removeAll(Collection collection) {
        Y0.d dVar = this.f5850a;
        int iD = dVar.d();
        int i4 = 0;
        boolean z4 = false;
        while (i4 < iD) {
            if (collection.contains(dVar.b(i4, 1))) {
                dVar.h(i4);
                i4--;
                iD--;
                z4 = true;
            }
            i4++;
        }
        return z4;
    }

    @Override // java.util.Collection
    public final boolean retainAll(Collection collection) {
        Y0.d dVar = this.f5850a;
        int iD = dVar.d();
        int i4 = 0;
        boolean z4 = false;
        while (i4 < iD) {
            if (!collection.contains(dVar.b(i4, 1))) {
                dVar.h(i4);
                i4--;
                iD--;
                z4 = true;
            }
            i4++;
        }
        return z4;
    }

    @Override // java.util.Collection
    public final int size() {
        return this.f5850a.d();
    }

    @Override // java.util.Collection
    public final Object[] toArray() {
        Y0.d dVar = this.f5850a;
        int iD = dVar.d();
        Object[] objArr = new Object[iD];
        for (int i4 = 0; i4 < iD; i4++) {
            objArr[i4] = dVar.b(i4, 1);
        }
        return objArr;
    }

    @Override // java.util.Collection
    public final Object[] toArray(Object[] objArr) {
        return this.f5850a.q(1, objArr);
    }
}
