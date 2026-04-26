package n;

import java.util.Collection;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/* JADX INFO: loaded from: classes.dex */
public final class h implements Set {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5844a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Y0.d f5845b;

    public /* synthetic */ h(Y0.d dVar, int i4) {
        this.f5844a = i4;
        this.f5845b = dVar;
    }

    @Override // java.util.Set, java.util.Collection
    public final boolean add(Object obj) {
        switch (this.f5844a) {
            case 0:
                throw new UnsupportedOperationException();
            default:
                throw new UnsupportedOperationException();
        }
    }

    @Override // java.util.Set, java.util.Collection
    public final boolean addAll(Collection collection) {
        switch (this.f5844a) {
            case 0:
                Y0.d dVar = this.f5845b;
                int iD = dVar.d();
                Iterator it = collection.iterator();
                while (it.hasNext()) {
                    Map.Entry entry = (Map.Entry) it.next();
                    dVar.g(entry.getKey(), entry.getValue());
                }
                return iD != dVar.d();
            default:
                throw new UnsupportedOperationException();
        }
    }

    @Override // java.util.Set, java.util.Collection
    public final void clear() {
        switch (this.f5844a) {
            case 0:
                this.f5845b.a();
                break;
            default:
                this.f5845b.a();
                break;
        }
    }

    @Override // java.util.Set, java.util.Collection
    public final boolean contains(Object obj) {
        switch (this.f5844a) {
            case 0:
                if (!(obj instanceof Map.Entry)) {
                    return false;
                }
                Map.Entry entry = (Map.Entry) obj;
                Object key = entry.getKey();
                Y0.d dVar = this.f5845b;
                int iE = dVar.e(key);
                if (iE < 0) {
                    return false;
                }
                Object objB = dVar.b(iE, 1);
                Object value = entry.getValue();
                return objB == value || (objB != null && objB.equals(value));
            default:
                return this.f5845b.e(obj) >= 0;
        }
    }

    @Override // java.util.Set, java.util.Collection
    public final boolean containsAll(Collection collection) {
        switch (this.f5844a) {
            case 0:
                Iterator it = collection.iterator();
                while (it.hasNext()) {
                    if (!contains(it.next())) {
                        break;
                    }
                }
                break;
            default:
                Map mapC = this.f5845b.c();
                Iterator it2 = collection.iterator();
                while (it2.hasNext()) {
                    if (!mapC.containsKey(it2.next())) {
                        break;
                    }
                }
                break;
        }
        return true;
    }

    @Override // java.util.Set, java.util.Collection
    public final boolean equals(Object obj) {
        switch (this.f5844a) {
        }
        return Y0.d.j(this, obj);
    }

    @Override // java.util.Set, java.util.Collection
    public final int hashCode() {
        switch (this.f5844a) {
            case 0:
                Y0.d dVar = this.f5845b;
                int iHashCode = 0;
                for (int iD = dVar.d() - 1; iD >= 0; iD--) {
                    Object objB = dVar.b(iD, 0);
                    Object objB2 = dVar.b(iD, 1);
                    iHashCode += (objB == null ? 0 : objB.hashCode()) ^ (objB2 == null ? 0 : objB2.hashCode());
                }
                return iHashCode;
            default:
                Y0.d dVar2 = this.f5845b;
                int iHashCode2 = 0;
                for (int iD2 = dVar2.d() - 1; iD2 >= 0; iD2--) {
                    Object objB3 = dVar2.b(iD2, 0);
                    iHashCode2 += objB3 == null ? 0 : objB3.hashCode();
                }
                return iHashCode2;
        }
    }

    @Override // java.util.Set, java.util.Collection
    public final boolean isEmpty() {
        switch (this.f5844a) {
            case 0:
                if (this.f5845b.d() == 0) {
                }
                break;
            default:
                if (this.f5845b.d() == 0) {
                }
                break;
        }
        return false;
    }

    @Override // java.util.Set, java.util.Collection, java.lang.Iterable
    public final Iterator iterator() {
        switch (this.f5844a) {
            case 0:
                return new i(this.f5845b);
            default:
                return new g(this.f5845b, 0);
        }
    }

    @Override // java.util.Set, java.util.Collection
    public final boolean remove(Object obj) {
        switch (this.f5844a) {
            case 0:
                throw new UnsupportedOperationException();
            default:
                Y0.d dVar = this.f5845b;
                int iE = dVar.e(obj);
                if (iE < 0) {
                    return false;
                }
                dVar.h(iE);
                return true;
        }
    }

    @Override // java.util.Set, java.util.Collection
    public final boolean removeAll(Collection collection) {
        switch (this.f5844a) {
            case 0:
                throw new UnsupportedOperationException();
            default:
                Map mapC = this.f5845b.c();
                int size = mapC.size();
                Iterator it = collection.iterator();
                while (it.hasNext()) {
                    mapC.remove(it.next());
                }
                return size != mapC.size();
        }
    }

    @Override // java.util.Set, java.util.Collection
    public final boolean retainAll(Collection collection) {
        switch (this.f5844a) {
            case 0:
                throw new UnsupportedOperationException();
            default:
                Map mapC = this.f5845b.c();
                int size = mapC.size();
                Iterator it = mapC.keySet().iterator();
                while (it.hasNext()) {
                    if (!collection.contains(it.next())) {
                        it.remove();
                    }
                }
                return size != mapC.size();
        }
    }

    @Override // java.util.Set, java.util.Collection
    public final int size() {
        switch (this.f5844a) {
        }
        return this.f5845b.d();
    }

    @Override // java.util.Set, java.util.Collection
    public final Object[] toArray(Object[] objArr) {
        switch (this.f5844a) {
            case 0:
                throw new UnsupportedOperationException();
            default:
                return this.f5845b.q(0, objArr);
        }
    }

    @Override // java.util.Set, java.util.Collection
    public final Object[] toArray() {
        switch (this.f5844a) {
            case 0:
                throw new UnsupportedOperationException();
            default:
                Y0.d dVar = this.f5845b;
                int iD = dVar.d();
                Object[] objArr = new Object[iD];
                for (int i4 = 0; i4 < iD; i4++) {
                    objArr[i4] = dVar.b(i4, 0);
                }
                return objArr;
        }
    }
}
