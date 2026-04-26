package androidx.datastore.preferences.protobuf;

import java.util.AbstractMap;
import java.util.AbstractSet;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeMap;

/* JADX INFO: loaded from: classes.dex */
public final class W extends AbstractMap {

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final /* synthetic */ int f2940f = 0;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public List f2941a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Map f2942b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f2943c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public volatile Z f2944d;
    public Map e;

    public static W f() {
        W w4 = new W();
        w4.f2941a = Collections.EMPTY_LIST;
        Map map = Collections.EMPTY_MAP;
        w4.f2942b = map;
        w4.e = map;
        return w4;
    }

    /* JADX WARN: Removed duplicated region for block: B:13:0x0024  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final int a(java.lang.Comparable r5) {
        /*
            r4 = this;
            java.util.List r0 = r4.f2941a
            int r0 = r0.size()
            int r1 = r0 + (-1)
            if (r1 < 0) goto L21
            java.util.List r2 = r4.f2941a
            java.lang.Object r2 = r2.get(r1)
            androidx.datastore.preferences.protobuf.X r2 = (androidx.datastore.preferences.protobuf.X) r2
            java.lang.Comparable r2 = r2.f2945a
            int r2 = r5.compareTo(r2)
            if (r2 <= 0) goto L1e
            int r0 = r0 + 1
        L1c:
            int r5 = -r0
            return r5
        L1e:
            if (r2 != 0) goto L21
            return r1
        L21:
            r0 = 0
        L22:
            if (r0 > r1) goto L43
            int r2 = r0 + r1
            int r2 = r2 / 2
            java.util.List r3 = r4.f2941a
            java.lang.Object r3 = r3.get(r2)
            androidx.datastore.preferences.protobuf.X r3 = (androidx.datastore.preferences.protobuf.X) r3
            java.lang.Comparable r3 = r3.f2945a
            int r3 = r5.compareTo(r3)
            if (r3 >= 0) goto L3c
            int r2 = r2 + (-1)
            r1 = r2
            goto L22
        L3c:
            if (r3 <= 0) goto L42
            int r2 = r2 + 1
            r0 = r2
            goto L22
        L42:
            return r2
        L43:
            int r0 = r0 + 1
            goto L1c
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.datastore.preferences.protobuf.W.a(java.lang.Comparable):int");
    }

    public final void b() {
        if (this.f2943c) {
            throw new UnsupportedOperationException();
        }
    }

    public final Map.Entry c(int i4) {
        return (Map.Entry) this.f2941a.get(i4);
    }

    @Override // java.util.AbstractMap, java.util.Map
    public final void clear() {
        b();
        if (!this.f2941a.isEmpty()) {
            this.f2941a.clear();
        }
        if (this.f2942b.isEmpty()) {
            return;
        }
        this.f2942b.clear();
    }

    @Override // java.util.AbstractMap, java.util.Map
    public final boolean containsKey(Object obj) {
        Comparable comparable = (Comparable) obj;
        return a(comparable) >= 0 || this.f2942b.containsKey(comparable);
    }

    public final Set d() {
        return this.f2942b.isEmpty() ? Collections.EMPTY_SET : this.f2942b.entrySet();
    }

    public final SortedMap e() {
        b();
        if (this.f2942b.isEmpty() && !(this.f2942b instanceof TreeMap)) {
            TreeMap treeMap = new TreeMap();
            this.f2942b = treeMap;
            this.e = treeMap.descendingMap();
        }
        return (SortedMap) this.f2942b;
    }

    @Override // java.util.AbstractMap, java.util.Map
    public final Set entrySet() {
        if (this.f2944d == null) {
            this.f2944d = new Z(this);
        }
        return this.f2944d;
    }

    @Override // java.util.AbstractMap, java.util.Map
    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof W)) {
            return super.equals(obj);
        }
        W w4 = (W) obj;
        int size = size();
        if (size == w4.size()) {
            int size2 = this.f2941a.size();
            if (size2 != w4.f2941a.size()) {
                return ((AbstractSet) entrySet()).equals(w4.entrySet());
            }
            for (int i4 = 0; i4 < size2; i4++) {
                if (c(i4).equals(w4.c(i4))) {
                }
            }
            if (size2 != size) {
                return this.f2942b.equals(w4.f2942b);
            }
            return true;
        }
        return false;
    }

    @Override // java.util.AbstractMap, java.util.Map
    /* JADX INFO: renamed from: g, reason: merged with bridge method [inline-methods] */
    public final Object put(Comparable comparable, Object obj) {
        b();
        int iA = a(comparable);
        if (iA >= 0) {
            return ((X) this.f2941a.get(iA)).setValue(obj);
        }
        b();
        if (this.f2941a.isEmpty() && !(this.f2941a instanceof ArrayList)) {
            this.f2941a = new ArrayList(16);
        }
        int i4 = -(iA + 1);
        if (i4 >= 16) {
            return e().put(comparable, obj);
        }
        if (this.f2941a.size() == 16) {
            X x4 = (X) this.f2941a.remove(15);
            e().put(x4.f2945a, x4.f2946b);
        }
        this.f2941a.add(i4, new X(this, comparable, obj));
        return null;
    }

    @Override // java.util.AbstractMap, java.util.Map
    public final Object get(Object obj) {
        Comparable comparable = (Comparable) obj;
        int iA = a(comparable);
        return iA >= 0 ? ((X) this.f2941a.get(iA)).f2946b : this.f2942b.get(comparable);
    }

    public final Object h(int i4) {
        b();
        Object obj = ((X) this.f2941a.remove(i4)).f2946b;
        if (!this.f2942b.isEmpty()) {
            Iterator it = e().entrySet().iterator();
            List list = this.f2941a;
            Map.Entry entry = (Map.Entry) it.next();
            list.add(new X(this, (Comparable) entry.getKey(), entry.getValue()));
            it.remove();
        }
        return obj;
    }

    @Override // java.util.AbstractMap, java.util.Map
    public final int hashCode() {
        int size = this.f2941a.size();
        int iHashCode = 0;
        for (int i4 = 0; i4 < size; i4++) {
            iHashCode += ((X) this.f2941a.get(i4)).hashCode();
        }
        return this.f2942b.size() > 0 ? this.f2942b.hashCode() + iHashCode : iHashCode;
    }

    @Override // java.util.AbstractMap, java.util.Map
    public final Object remove(Object obj) {
        b();
        Comparable comparable = (Comparable) obj;
        int iA = a(comparable);
        if (iA >= 0) {
            return h(iA);
        }
        if (this.f2942b.isEmpty()) {
            return null;
        }
        return this.f2942b.remove(comparable);
    }

    @Override // java.util.AbstractMap, java.util.Map
    public final int size() {
        return this.f2942b.size() + this.f2941a.size();
    }
}
