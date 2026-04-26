package androidx.datastore.preferences.protobuf;

import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import java.io.IOException;
import java.util.Collections;
import java.util.Iterator;
import java.util.Map;

/* JADX INFO: renamed from: androidx.datastore.preferences.protobuf.p, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0205p {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ int f3010c = 0;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final W f3011a = W.f();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public boolean f3012b;

    static {
        new C0205p(0);
    }

    public C0205p() {
    }

    public static void b(C0200k c0200k, p0 p0Var, int i4, Object obj) throws IOException {
        if (p0Var == p0.f3014d) {
            c0200k.O0(i4, 3);
            ((AbstractC0190a) obj).b(c0200k);
            c0200k.O0(i4, 4);
        }
        c0200k.O0(i4, p0Var.f3017b);
        switch (p0Var.ordinal()) {
            case 0:
                c0200k.I0(Double.doubleToRawLongBits(((Double) obj).doubleValue()));
                break;
            case 1:
                c0200k.G0(Float.floatToRawIntBits(((Float) obj).floatValue()));
                break;
            case 2:
                c0200k.S0(((Long) obj).longValue());
                break;
            case 3:
                c0200k.S0(((Long) obj).longValue());
                break;
            case 4:
                c0200k.K0(((Integer) obj).intValue());
                break;
            case 5:
                c0200k.I0(((Long) obj).longValue());
                break;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                c0200k.G0(((Integer) obj).intValue());
                break;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                c0200k.A0(((Boolean) obj).booleanValue() ? (byte) 1 : (byte) 0);
                break;
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                if (!(obj instanceof C0196g)) {
                    c0200k.N0((String) obj);
                } else {
                    c0200k.E0((C0196g) obj);
                }
                break;
            case 9:
                ((AbstractC0190a) obj).b(c0200k);
                break;
            case 10:
                AbstractC0190a abstractC0190a = (AbstractC0190a) obj;
                c0200k.getClass();
                c0200k.Q0(((AbstractC0209u) abstractC0190a).a(null));
                abstractC0190a.b(c0200k);
                break;
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                if (!(obj instanceof C0196g)) {
                    byte[] bArr = (byte[]) obj;
                    int length = bArr.length;
                    c0200k.Q0(length);
                    c0200k.B0(bArr, 0, length);
                } else {
                    c0200k.E0((C0196g) obj);
                }
                break;
            case 12:
                c0200k.Q0(((Integer) obj).intValue());
                break;
            case 13:
                c0200k.K0(((Integer) obj).intValue());
                break;
            case 14:
                c0200k.G0(((Integer) obj).intValue());
                break;
            case 15:
                c0200k.I0(((Long) obj).longValue());
                break;
            case 16:
                int iIntValue = ((Integer) obj).intValue();
                c0200k.Q0((iIntValue >> 31) ^ (iIntValue << 1));
                break;
            case 17:
                long jLongValue = ((Long) obj).longValue();
                c0200k.S0((jLongValue >> 63) ^ (jLongValue << 1));
                break;
        }
    }

    public final void a() {
        if (this.f3012b) {
            return;
        }
        W w4 = this.f3011a;
        int size = w4.f2941a.size();
        for (int i4 = 0; i4 < size; i4++) {
            Map.Entry entryC = w4.c(i4);
            if (entryC.getValue() instanceof AbstractC0209u) {
                AbstractC0209u abstractC0209u = (AbstractC0209u) entryC.getValue();
                abstractC0209u.getClass();
                Q q4 = Q.f2927c;
                q4.getClass();
                q4.a(abstractC0209u.getClass()).d(abstractC0209u);
                abstractC0209u.h();
            }
        }
        if (!w4.f2943c) {
            if (w4.f2941a.size() > 0) {
                w4.c(0).getKey().getClass();
                throw new ClassCastException();
            }
            Iterator it = w4.d().iterator();
            if (it.hasNext()) {
                ((Map.Entry) it.next()).getKey().getClass();
                throw new ClassCastException();
            }
        }
        if (!w4.f2943c) {
            w4.f2942b = w4.f2942b.isEmpty() ? Collections.EMPTY_MAP : Collections.unmodifiableMap(w4.f2942b);
            w4.e = w4.e.isEmpty() ? Collections.EMPTY_MAP : Collections.unmodifiableMap(w4.e);
            w4.f2943c = true;
        }
        this.f3012b = true;
    }

    public final Object clone() {
        C0205p c0205p = new C0205p();
        W w4 = this.f3011a;
        if (w4.f2941a.size() > 0) {
            Map.Entry entryC = w4.c(0);
            if (entryC.getKey() != null) {
                throw new ClassCastException();
            }
            entryC.getValue();
            throw null;
        }
        Iterator it = w4.d().iterator();
        if (!it.hasNext()) {
            return c0205p;
        }
        Map.Entry entry = (Map.Entry) it.next();
        if (entry.getKey() != null) {
            throw new ClassCastException();
        }
        entry.getValue();
        throw null;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj instanceof C0205p) {
            return this.f3011a.equals(((C0205p) obj).f3011a);
        }
        return false;
    }

    public final int hashCode() {
        return this.f3011a.hashCode();
    }

    public C0205p(int i4) {
        a();
        a();
    }
}
