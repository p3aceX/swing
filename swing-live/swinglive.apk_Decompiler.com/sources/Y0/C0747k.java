package y0;

import D2.C;
import D2.D;
import D2.E;
import D2.H;
import D2.v;
import D2.z;
import I.C0053n;
import O.RunnableC0093d;
import O2.r;
import S0.p;
import S0.q;
import S0.s;
import T2.t;
import X.AbstractC0170a;
import X.C0171b;
import a.AbstractC0184a;
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.ColorStateList;
import android.content.res.Resources;
import android.content.res.TypedArray;
import android.graphics.PointF;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.util.TypedValue;
import android.view.KeyEvent;
import android.view.View;
import androidx.recyclerview.widget.RecyclerView;
import b.C0229f;
import b1.C0243a;
import c1.InterfaceC0250a;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.crypto.tink.shaded.protobuf.B;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import d1.N;
import d1.f0;
import d1.g0;
import d1.r0;
import e1.AbstractC0367g;
import f1.C0400a;
import g.AbstractC0404a;
import io.flutter.embedding.engine.FlutterJNI;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.Serializable;
import java.nio.ByteBuffer;
import java.security.GeneralSecurityException;
import java.security.InvalidAlgorithmParameterException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.WeakHashMap;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicReference;
import java.util.concurrent.locks.ReentrantLock;
import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import k.C0502t;
import l3.C0528e;
import l3.C0530g;
import l3.InterfaceC0529f;
import l3.L;
import l3.M;
import l3.O;
import m1.RunnableC0550e;
import org.json.JSONException;
import org.xmlpull.v1.XmlPullParserException;
import s.AbstractC0658b;
import u1.C0690c;
import x3.AbstractC0728h;
import z0.C0779j;

/* JADX INFO: renamed from: y0.k, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0747k implements O2.d, InterfaceC0250a, InterfaceC0529f {
    public static C0747k e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static C0747k f6829f;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f6830a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f6831b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Object f6832c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Object f6833d;

    public /* synthetic */ C0747k(int i4, boolean z4) {
        this.f6830a = i4;
    }

    public static final C0747k D(g0 g0Var) throws GeneralSecurityException {
        if (g0Var.z() <= 0) {
            throw new GeneralSecurityException("empty keyset");
        }
        ArrayList arrayList = new ArrayList(g0Var.z());
        for (f0 f0Var : g0Var.A()) {
            f0Var.getClass();
            try {
                try {
                    R0.b bVarA = Y0.h.f2478b.a(Y0.n.b(f0Var.A().B(), f0Var.A().C(), f0Var.A().A(), f0Var.C(), f0Var.C() == r0.RAW ? null : Integer.valueOf(f0Var.B())));
                    int iOrdinal = f0Var.D().ordinal();
                    if (iOrdinal != 1 && iOrdinal != 2 && iOrdinal != 3) {
                        throw new GeneralSecurityException("Unknown key status");
                    }
                    arrayList.add(new R0.h(bVarA));
                } catch (GeneralSecurityException unused) {
                    arrayList.add(null);
                }
            } catch (GeneralSecurityException e4) {
                throw new A0.b("Creating a protokey serialization failed", e4);
            }
        }
        return new C0747k(g0Var, Collections.unmodifiableList(arrayList));
    }

    public static C0747k N() {
        if (f6829f == null) {
            p1.d dVar = new p1.d(1);
            C2.a aVar = new C2.a();
            aVar.f129a = 0;
            ExecutorService executorServiceNewCachedThreadPool = Executors.newCachedThreadPool(aVar);
            FlutterJNI flutterJNI = new FlutterJNI();
            I2.e eVar = new I2.e();
            eVar.f761a = false;
            eVar.e = flutterJNI;
            eVar.f765f = executorServiceNewCachedThreadPool;
            C0747k c0747k = new C0747k(2, false);
            c0747k.f6831b = eVar;
            c0747k.f6832c = dVar;
            c0747k.f6833d = executorServiceNewCachedThreadPool;
            f6829f = c0747k;
        }
        return f6829f;
    }

    public static C0747k P(Context context, AttributeSet attributeSet, int[] iArr, int i4) {
        return new C0747k(context, context.obtainStyledAttributes(attributeSet, iArr, i4, 0));
    }

    public static final C0747k S(R0.f fVar, X0.b bVar) throws GeneralSecurityException, IOException {
        byte[] bArr = new byte[0];
        ByteArrayInputStream byteArrayInputStream = (ByteArrayInputStream) fVar.f1686b;
        try {
            N nA = N.A(byteArrayInputStream, C0309n.a());
            byteArrayInputStream.close();
            if (nA.y().size() == 0) {
                throw new GeneralSecurityException("empty keyset");
            }
            try {
                g0 g0VarE = g0.E(bVar.b(nA.y().j(), bArr), C0309n.a());
                if (g0VarE.z() > 0) {
                    return D(g0VarE);
                }
                throw new GeneralSecurityException("empty keyset");
            } catch (B unused) {
                throw new GeneralSecurityException("invalid keyset, corrupted key material");
            }
        } catch (Throwable th) {
            byteArrayInputStream.close();
            throw th;
        }
    }

    public static PointF V(PointF pointF, PointF pointF2) {
        float f4 = 0;
        if (f4 > 180.0f) {
            f4 -= 360.0f;
        }
        double d5 = (((double) f4) * 3.141592653589793d) / 180.0d;
        float fCos = (float) Math.cos(d5);
        float fSin = (float) Math.sin(d5);
        float f5 = pointF.x - pointF2.x;
        float f6 = pointF.y - pointF2.y;
        return new PointF(pointF2.x + ((f5 * fCos) - (f6 * fSin)), pointF2.y + (f5 * fSin) + (f6 * fCos));
    }

    public static synchronized C0747k b0(Context context) {
        C0747k c0747k;
        Context applicationContext = context.getApplicationContext();
        synchronized (C0747k.class) {
            c0747k = e;
            if (c0747k == null) {
                c0747k = new C0747k(applicationContext);
                e = c0747k;
            }
        }
        return c0747k;
        return c0747k;
    }

    public void A(int i4, io.flutter.view.h hVar, Serializable serializable) {
        ((FlutterJNI) this.f6832c).dispatchSemanticsAction(i4, hVar, serializable);
    }

    public void B(t tVar, String str, String str2) {
        ((Handler) this.f6831b).post(new RunnableC0550e(tVar, str, str2, 3));
    }

    public int C(int i4, int i5) {
        ArrayList arrayList = (ArrayList) this.f6833d;
        int size = arrayList.size();
        while (i5 < size) {
            ((AbstractC0170a) arrayList.get(i5)).getClass();
            i5++;
        }
        return i4;
    }

    public ColorStateList E(int i4) {
        int resourceId;
        TypedArray typedArray = (TypedArray) this.f6832c;
        if (typedArray.hasValue(i4) && (resourceId = typedArray.getResourceId(i4, 0)) != 0) {
            Object obj = AbstractC0404a.f4294a;
            ColorStateList colorStateList = ((Context) this.f6831b).getColorStateList(resourceId);
            if (colorStateList != null) {
                return colorStateList;
            }
        }
        return typedArray.getColorStateList(i4);
    }

    public Drawable F(int i4) {
        int resourceId;
        TypedArray typedArray = (TypedArray) this.f6832c;
        return (!typedArray.hasValue(i4) || (resourceId = typedArray.getResourceId(i4, 0)) == 0) ? typedArray.getDrawable(i4) : AbstractC0404a.a((Context) this.f6831b, resourceId);
    }

    public Typeface G(int i4, int i5, C0502t c0502t) {
        C0502t c0502t2;
        XmlPullParserException xmlPullParserException;
        IOException iOException;
        int i6 = 12;
        int resourceId = ((TypedArray) this.f6832c).getResourceId(i4, 0);
        if (resourceId != 0) {
            if (((TypedValue) this.f6833d) == null) {
                this.f6833d = new TypedValue();
            }
            TypedValue typedValue = (TypedValue) this.f6833d;
            ThreadLocal threadLocal = s.l.f6458a;
            Context context = (Context) this.f6831b;
            if (!context.isRestricted()) {
                Resources resources = context.getResources();
                resources.getValue(resourceId, typedValue, true);
                CharSequence charSequence = typedValue.string;
                if (charSequence == null) {
                    throw new Resources.NotFoundException("Resource \"" + resources.getResourceName(resourceId) + "\" (" + Integer.toHexString(resourceId) + ") is not a Font: " + typedValue);
                }
                String string = charSequence.toString();
                if (!string.startsWith("res/")) {
                    c0502t.a();
                    return null;
                }
                int i7 = typedValue.assetCookie;
                n.f fVar = t.d.f6515b;
                Typeface typeface = (Typeface) fVar.get(t.d.b(resources, resourceId, string, i7, i5));
                if (typeface != null) {
                    new Handler(Looper.getMainLooper()).post(new RunnableC0093d(i6, c0502t, typeface));
                    return typeface;
                }
                try {
                } catch (IOException e4) {
                    e = e4;
                    c0502t2 = c0502t;
                } catch (XmlPullParserException e5) {
                    e = e5;
                    c0502t2 = c0502t;
                }
                try {
                    if (!string.toLowerCase().endsWith(".xml")) {
                        int i8 = typedValue.assetCookie;
                        Typeface typefaceL = t.d.f6514a.l(context, resources, resourceId, string, i5);
                        if (typefaceL != null) {
                            fVar.put(t.d.b(resources, resourceId, string, i8, i5), typefaceL);
                        }
                        if (typefaceL != null) {
                            new Handler(Looper.getMainLooper()).post(new RunnableC0093d(i6, c0502t, typefaceL));
                        } else {
                            c0502t.a();
                        }
                        return typefaceL;
                    }
                    s.e eVarD = AbstractC0658b.d(resources.getXml(resourceId), resources);
                    if (eVarD != null) {
                        return t.d.a(context, eVarD, resources, resourceId, string, typedValue.assetCookie, i5, c0502t);
                    }
                    try {
                        Log.e("ResourcesCompat", "Failed to find font-family tag");
                        c0502t.a();
                        return null;
                    } catch (IOException e6) {
                        iOException = e6;
                        c0502t2 = c0502t;
                    } catch (XmlPullParserException e7) {
                        xmlPullParserException = e7;
                        c0502t2 = c0502t;
                        Log.e("ResourcesCompat", "Failed to parse xml resource ".concat(string), xmlPullParserException);
                        c0502t2.a();
                        return null;
                    }
                } catch (IOException e8) {
                    e = e8;
                    iOException = e;
                } catch (XmlPullParserException e9) {
                    e = e9;
                    xmlPullParserException = e;
                    Log.e("ResourcesCompat", "Failed to parse xml resource ".concat(string), xmlPullParserException);
                    c0502t2.a();
                    return null;
                }
                iOException = e;
                Log.e("ResourcesCompat", "Failed to read xml resource ".concat(string), iOException);
                c0502t2.a();
                return null;
            }
        }
        return null;
    }

    /* JADX WARN: Removed duplicated region for block: B:72:0x016b  */
    /* JADX WARN: Removed duplicated region for block: B:73:0x016f  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public java.lang.Object H(java.lang.Class r15) throws java.security.GeneralSecurityException {
        /*
            Method dump skipped, instruction units count: 522
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: y0.C0747k.H(java.lang.Class):java.lang.Object");
    }

    public List I(byte[] bArr) {
        List list = (List) ((ConcurrentHashMap) this.f6831b).get(new R0.m(bArr));
        return list != null ? list : Collections.EMPTY_LIST;
    }

    public float[] J() {
        float[] fArr = (float[]) this.f6831b;
        PointF pointF = new PointF(fArr[0], fArr[1]);
        PointF pointF2 = new PointF(fArr[2], fArr[3]);
        PointF pointF3 = new PointF(fArr[4], fArr[5]);
        PointF pointF4 = new PointF(fArr[6], fArr[7]);
        PointF pointF5 = (PointF) this.f6832c;
        float f4 = pointF5.x / 100.0f;
        float f5 = pointF5.y / 100.0f;
        pointF.x /= f4;
        pointF.y /= f5;
        pointF2.x /= f4;
        pointF2.y /= f5;
        pointF3.x /= f4;
        pointF3.y /= f5;
        pointF4.x /= f4;
        pointF4.y /= f5;
        PointF pointF6 = (PointF) this.f6833d;
        float f6 = (-pointF6.x) / pointF5.x;
        float f7 = (-pointF6.y) / pointF5.y;
        pointF.x += f6;
        pointF.y += f7;
        pointF2.x += f6;
        pointF2.y += f7;
        pointF3.x += f6;
        pointF3.y += f7;
        pointF4.x += f6;
        pointF4.y += f7;
        PointF pointF7 = new PointF(0.5f, 0.5f);
        PointF pointFV = V(pointF2, pointF7);
        PointF pointFV2 = V(pointF, pointF7);
        PointF pointFV3 = V(pointF4, pointF7);
        PointF pointFV4 = V(pointF3, pointF7);
        return new float[]{pointFV2.x, pointFV2.y, pointFV.x, pointFV.y, pointFV4.x, pointFV4.y, pointFV3.x, pointFV3.y};
    }

    public View K(int i4) {
        return ((RecyclerView) ((C0690c) this.f6831b).f6642b).getChildAt(i4);
    }

    public int L() {
        return ((RecyclerView) ((C0690c) this.f6831b).f6642b).getChildCount();
    }

    public boolean M(KeyEvent keyEvent) {
        if (((HashSet) this.f6832c).remove(keyEvent)) {
            return false;
        }
        D[] dArr = (D[]) this.f6831b;
        if (dArr.length <= 0) {
            Q(keyEvent);
            return true;
        }
        C c5 = new C();
        c5.f160d = this;
        c5.f158b = ((D[]) this.f6831b).length;
        c5.f157a = false;
        c5.f159c = keyEvent;
        for (D d5 : dArr) {
            d5.a(keyEvent, new D2.B(c5));
        }
        return true;
    }

    public void O(String str, Object obj, N2.j jVar) {
        ((O2.f) this.f6831b).s((String) this.f6832c, ((O2.n) this.f6833d).a(new v(str, obj, 15, false)), jVar == null ? null : new O2.a(1, this, jVar));
    }

    /* JADX WARN: Removed duplicated region for block: B:33:0x0090  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public void Q(android.view.KeyEvent r9) {
        /*
            Method dump skipped, instruction units count: 234
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: y0.C0747k.Q(android.view.KeyEvent):void");
    }

    public void R(Activity activity, i0.j jVar) {
        J3.i.e(activity, "activity");
        ReentrantLock reentrantLock = (ReentrantLock) this.f6832c;
        reentrantLock.lock();
        WeakHashMap weakHashMap = (WeakHashMap) this.f6833d;
        try {
            if (jVar.equals((i0.j) weakHashMap.get(activity))) {
                return;
            }
            reentrantLock.unlock();
            for (l0.j jVar2 : ((l0.k) ((B.k) this.f6831b).f104b).f5588b) {
                if (jVar2.f5582a.equals(activity)) {
                    jVar2.f5584c = jVar;
                    jVar2.f5583b.accept(jVar);
                }
            }
        } finally {
            reentrantLock.unlock();
        }
    }

    public void T() {
        ((TypedArray) this.f6832c).recycle();
    }

    /* JADX WARN: Code restructure failed: missing block: B:12:0x0032, code lost:
    
        r4 = r3.f163a;
     */
    /* JADX WARN: Code restructure failed: missing block: B:13:0x0035, code lost:
    
        if (r4 >= r6.length) goto L21;
     */
    /* JADX WARN: Code restructure failed: missing block: B:14:0x0037, code lost:
    
        r6[r4] = r2;
        r3.f163a = r4 + 1;
     */
    /* JADX WARN: Code restructure failed: missing block: B:15:0x003d, code lost:
    
        r1 = r1 + 1;
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public void U(java.util.ArrayList r8) {
        /*
            r7 = this;
            int r0 = r8.size()
            r1 = 0
        L5:
            if (r1 >= r0) goto L40
            java.lang.Object r2 = r8.get(r1)
            X.a r2 = (X.AbstractC0170a) r2
            r2.getClass()
            java.lang.Object r3 = r7.f6831b
            D2.H r3 = (D2.H) r3
            r3.getClass()
            java.lang.String r4 = "instance"
            J3.i.e(r2, r4)
            int r4 = r3.f163a
            r5 = 0
        L1f:
            java.lang.Object[] r6 = r3.f164b
            if (r5 >= r4) goto L32
            r6 = r6[r5]
            if (r6 == r2) goto L2a
            int r5 = r5 + 1
            goto L1f
        L2a:
            java.lang.IllegalStateException r8 = new java.lang.IllegalStateException
            java.lang.String r0 = "Already in the pool!"
            r8.<init>(r0)
            throw r8
        L32:
            int r4 = r3.f163a
            int r5 = r6.length
            if (r4 >= r5) goto L3d
            r6[r4] = r2
            int r4 = r4 + 1
            r3.f163a = r4
        L3d:
            int r1 = r1 + 1
            goto L5
        L40:
            r8.clear()
            return
        */
        throw new UnsupportedOperationException("Method not decompiled: y0.C0747k.U(java.util.ArrayList):void");
    }

    public void W(String str) {
        ((Handler) this.f6831b).post(new RunnableC0093d(5, this, str));
    }

    public void X(int i4) throws InvalidAlgorithmParameterException {
        if (i4 != 16 && i4 != 32) {
            throw new InvalidAlgorithmParameterException(String.format("Invalid key size %d; only 128-bit and 256-bit AES keys are supported", Integer.valueOf(i4 * 8)));
        }
        this.f6831b = Integer.valueOf(i4);
    }

    public void Y(O2.m mVar) {
        ((O2.f) this.f6831b).p((String) this.f6832c, mVar == null ? null : new v(16, this, mVar));
    }

    public void Z(O2.h hVar) {
        ((O2.f) this.f6831b).p((String) this.f6832c, hVar == null ? null : new C0747k(this, hVar));
    }

    @Override // l3.InterfaceC0529f
    public void a(String str, String str2, C0530g c0530g) {
        y(c0530g).edit().putString(str, str2).apply();
    }

    public void a0() {
        Integer num;
        C0229f c0229f = (C0229f) this.f6833d;
        ArrayList arrayList = c0229f.f3218d;
        String str = (String) this.f6831b;
        if (!arrayList.contains(str) && (num = (Integer) c0229f.f3216b.remove(str)) != null) {
            c0229f.f3215a.remove(num);
        }
        c0229f.e.remove(str);
        HashMap map = c0229f.f3219f;
        if (map.containsKey(str)) {
            Log.w("ActivityResultRegistry", "Dropping pending result for request " + str + ": " + map.get(str));
            map.remove(str);
        }
        Bundle bundle = c0229f.f3220g;
        if (bundle.containsKey(str)) {
            Log.w("ActivityResultRegistry", "Dropping pending result for request " + str + ": " + bundle.getParcelable(str));
            bundle.remove(str);
        }
        if (c0229f.f3217c.get(str) != null) {
            throw new ClassCastException();
        }
    }

    @Override // l3.InterfaceC0529f
    public void b(String str, long j4, C0530g c0530g) {
        y(c0530g).edit().putLong(str, j4).apply();
    }

    @Override // O2.d
    public void c(ByteBuffer byteBuffer, F2.g gVar) {
        C0747k c0747k = (C0747k) this.f6833d;
        String str = (String) ((r) c0747k.f6833d).c(byteBuffer).f260b;
        boolean zEquals = str.equals("listen");
        AtomicReference atomicReference = (AtomicReference) this.f6832c;
        String str2 = (String) c0747k.f6832c;
        r rVar = (r) c0747k.f6833d;
        O2.h hVar = (O2.h) this.f6831b;
        if (!zEquals) {
            if (!str.equals("cancel")) {
                gVar.a(null);
                return;
            }
            if (((O2.g) atomicReference.getAndSet(null)) == null) {
                gVar.a(rVar.f(null, "error", "No active stream to cancel"));
                return;
            }
            try {
                hVar.n();
                gVar.a(rVar.b(null));
                return;
            } catch (RuntimeException e4) {
                Log.e("EventChannel#" + str2, "Failed to close event stream", e4);
                gVar.a(rVar.f(null, "error", e4.getMessage()));
                return;
            }
        }
        O2.g gVar2 = new O2.g(this);
        if (((O2.g) atomicReference.getAndSet(gVar2)) != null) {
            try {
                hVar.n();
            } catch (RuntimeException e5) {
                Log.e("EventChannel#" + str2, "Failed to close existing event stream", e5);
            }
        }
        try {
            hVar.a(gVar2);
            gVar.a(rVar.b(null));
        } catch (RuntimeException e6) {
            atomicReference.set(null);
            Log.e("EventChannel#" + str2, "Failed to open event stream", e6);
            gVar.a(rVar.f(null, "error", e6.getMessage()));
        }
    }

    public synchronized void c0() {
        C0738b c0738b = (C0738b) this.f6831b;
        ReentrantLock reentrantLock = c0738b.f6808a;
        reentrantLock.lock();
        try {
            c0738b.f6809b.edit().clear().apply();
            reentrantLock.unlock();
            this.f6832c = null;
            this.f6833d = null;
        } catch (Throwable th) {
            reentrantLock.unlock();
            throw th;
        }
    }

    @Override // l3.InterfaceC0529f
    public void d(String str, List list, C0530g c0530g) {
        y(c0530g).edit().putString(str, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu".concat(((X.N) this.f6833d).e(list))).apply();
    }

    @Override // l3.InterfaceC0529f
    public String e(String str, C0530g c0530g) {
        SharedPreferences sharedPreferencesY = y(c0530g);
        if (sharedPreferencesY.contains(str)) {
            return sharedPreferencesY.getString(str, "");
        }
        return null;
    }

    @Override // l3.InterfaceC0529f
    public Boolean f(String str, C0530g c0530g) {
        SharedPreferences sharedPreferencesY = y(c0530g);
        if (sharedPreferencesY.contains(str)) {
            return Boolean.valueOf(sharedPreferencesY.getBoolean(str, true));
        }
        return null;
    }

    @Override // l3.InterfaceC0529f
    public List g(List list, C0530g c0530g) {
        Map<String, ?> all = y(c0530g).getAll();
        J3.i.d(all, "getAll(...)");
        LinkedHashMap linkedHashMap = new LinkedHashMap();
        for (Map.Entry<String, ?> entry : all.entrySet()) {
            String key = entry.getKey();
            J3.i.d(key, "<get-key>(...)");
            if (L.b(key, entry.getValue(), list != null ? AbstractC0728h.m0(list) : null)) {
                linkedHashMap.put(entry.getKey(), entry.getValue());
            }
        }
        return AbstractC0728h.i0(linkedHashMap.keySet());
    }

    @Override // l3.InterfaceC0529f
    public O h(String str, C0530g c0530g) {
        SharedPreferences sharedPreferencesY = y(c0530g);
        if (!sharedPreferencesY.contains(str)) {
            return null;
        }
        String string = sharedPreferencesY.getString(str, "");
        J3.i.b(string);
        return P3.m.F0(string, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu!") ? new O(string, M.f5667d) : P3.m.F0(string, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu") ? new O(null, M.f5666c) : new O(null, M.e);
    }

    @Override // l3.InterfaceC0529f
    public Map i(List list, C0530g c0530g) {
        Object value;
        Map<String, ?> all = y(c0530g).getAll();
        J3.i.d(all, "getAll(...)");
        HashMap map = new HashMap();
        for (Map.Entry<String, ?> entry : all.entrySet()) {
            if (L.b(entry.getKey(), entry.getValue(), list != null ? AbstractC0728h.m0(list) : null) && (value = entry.getValue()) != null) {
                String key = entry.getKey();
                Object objC = L.c(value, (X.N) this.f6833d);
                J3.i.c(objC, "null cannot be cast to non-null type kotlin.Any");
                map.put(key, objC);
            }
        }
        return map;
    }

    @Override // l3.InterfaceC0529f
    public Long j(String str, C0530g c0530g) {
        long j4;
        SharedPreferences sharedPreferencesY = y(c0530g);
        if (!sharedPreferencesY.contains(str)) {
            return null;
        }
        try {
            j4 = sharedPreferencesY.getLong(str, 0L);
        } catch (ClassCastException unused) {
            j4 = sharedPreferencesY.getInt(str, 0);
        }
        return Long.valueOf(j4);
    }

    @Override // l3.InterfaceC0529f
    public ArrayList k(String str, C0530g c0530g) {
        List list;
        SharedPreferences sharedPreferencesY = y(c0530g);
        if (!sharedPreferencesY.contains(str)) {
            return null;
        }
        String string = sharedPreferencesY.getString(str, "");
        J3.i.b(string);
        if (!P3.m.F0(string, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu") || P3.m.F0(string, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu!") || (list = (List) L.c(sharedPreferencesY.getString(str, ""), (X.N) this.f6833d)) == null) {
            return null;
        }
        ArrayList arrayList = new ArrayList();
        for (Object obj : list) {
            if (obj instanceof String) {
                arrayList.add(obj);
            }
        }
        return arrayList;
    }

    @Override // l3.InterfaceC0529f
    public Double l(String str, C0530g c0530g) {
        SharedPreferences sharedPreferencesY = y(c0530g);
        if (!sharedPreferencesY.contains(str)) {
            return null;
        }
        Object objC = L.c(sharedPreferencesY.getString(str, ""), (X.N) this.f6833d);
        J3.i.c(objC, "null cannot be cast to non-null type kotlin.Double");
        return (Double) objC;
    }

    @Override // c1.InterfaceC0250a
    public byte[] m(byte[] bArr, int i4) throws GeneralSecurityException {
        byte[] bArrY;
        if (i4 > 16) {
            throw new InvalidAlgorithmParameterException("outputLength too large, max is 16 bytes");
        }
        if (!B1.a.f(1)) {
            throw new GeneralSecurityException("Can not use AES-CMAC in FIPS-mode.");
        }
        Cipher cipher = (Cipher) e1.j.f3998b.f4000a.e("AES/ECB/NoPadding");
        cipher.init(1, (SecretKeySpec) this.f6831b);
        int iMax = Math.max(1, (int) Math.ceil(((double) bArr.length) / 16.0d));
        if (iMax * 16 == bArr.length) {
            bArrY = AbstractC0367g.X(bArr, (iMax - 1) * 16, (byte[]) this.f6832c, 0, 16);
        } else {
            byte[] bArrCopyOfRange = Arrays.copyOfRange(bArr, (iMax - 1) * 16, bArr.length);
            if (bArrCopyOfRange.length >= 16) {
                throw new IllegalArgumentException("x must be smaller than a block.");
            }
            byte[] bArrCopyOf = Arrays.copyOf(bArrCopyOfRange, 16);
            bArrCopyOf[bArrCopyOfRange.length] = -128;
            bArrY = AbstractC0367g.Y(bArrCopyOf, (byte[]) this.f6833d);
        }
        byte[] bArrDoFinal = new byte[16];
        for (int i5 = 0; i5 < iMax - 1; i5++) {
            bArrDoFinal = cipher.doFinal(AbstractC0367g.X(bArrDoFinal, 0, bArr, i5 * 16, 16));
        }
        return Arrays.copyOf(cipher.doFinal(AbstractC0367g.Y(bArrY, bArrDoFinal)), i4);
    }

    @Override // l3.InterfaceC0529f
    public void n(String str, boolean z4, C0530g c0530g) {
        y(c0530g).edit().putBoolean(str, z4).apply();
    }

    @Override // l3.InterfaceC0529f
    public void o(String str, double d5, C0530g c0530g) {
        y(c0530g).edit().putString(str, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu" + d5).apply();
    }

    @Override // l3.InterfaceC0529f
    public void p(String str, String str2, C0530g c0530g) {
        y(c0530g).edit().putString(str, str2).apply();
    }

    @Override // l3.InterfaceC0529f
    public void q(List list, C0530g c0530g) {
        SharedPreferences sharedPreferencesY = y(c0530g);
        SharedPreferences.Editor editorEdit = sharedPreferencesY.edit();
        J3.i.d(editorEdit, "edit(...)");
        Map<String, ?> all = sharedPreferencesY.getAll();
        J3.i.d(all, "getAll(...)");
        ArrayList arrayList = new ArrayList();
        for (String str : all.keySet()) {
            if (L.b(str, all.get(str), list != null ? AbstractC0728h.m0(list) : null)) {
                arrayList.add(str);
            }
        }
        Iterator it = arrayList.iterator();
        J3.i.d(it, "iterator(...)");
        while (it.hasNext()) {
            Object next = it.next();
            J3.i.d(next, "next(...)");
            editorEdit.remove((String) next);
        }
        editorEdit.apply();
    }

    public S0.m r() throws GeneralSecurityException {
        C0690c c0690c;
        S0.n nVar = (S0.n) this.f6831b;
        if (nVar == null || (c0690c = (C0690c) this.f6832c) == null) {
            throw new GeneralSecurityException("Cannot build without parameters and/or key material");
        }
        if (nVar.f1768b != ((C0400a) c0690c.f6642b).f4284a.length) {
            throw new GeneralSecurityException("Key size mismatch");
        }
        S0.j jVar = S0.j.f1746m;
        S0.j jVar2 = nVar.e;
        if (jVar2 != jVar && ((Integer) this.f6833d) == null) {
            throw new GeneralSecurityException("Cannot create key without ID requirement with parameters with ID requirement");
        }
        if (jVar2 == jVar && ((Integer) this.f6833d) != null) {
            throw new GeneralSecurityException("Cannot create key with ID requirement with parameters without ID requirement");
        }
        if (jVar2 == jVar) {
            C0400a.a(new byte[0]);
        } else if (jVar2 == S0.j.f1745l) {
            C0400a.a(ByteBuffer.allocate(5).put((byte) 0).putInt(((Integer) this.f6833d).intValue()).array());
        } else {
            if (jVar2 != S0.j.f1744k) {
                throw new IllegalStateException("Unknown AesEaxParameters.Variant: " + ((S0.n) this.f6831b).e);
            }
            C0400a.a(ByteBuffer.allocate(5).put((byte) 1).putInt(((Integer) this.f6833d).intValue()).array());
        }
        return new S0.m();
    }

    public p s() throws GeneralSecurityException {
        C0690c c0690c;
        q qVar = (q) this.f6831b;
        if (qVar == null || (c0690c = (C0690c) this.f6832c) == null) {
            throw new GeneralSecurityException("Cannot build without parameters and/or key material");
        }
        if (qVar.f1775b != ((C0400a) c0690c.f6642b).f4284a.length) {
            throw new GeneralSecurityException("Key size mismatch");
        }
        S0.j jVar = S0.j.f1749p;
        S0.j jVar2 = qVar.e;
        if (jVar2 != jVar && ((Integer) this.f6833d) == null) {
            throw new GeneralSecurityException("Cannot create key without ID requirement with parameters with ID requirement");
        }
        if (jVar2 == jVar && ((Integer) this.f6833d) != null) {
            throw new GeneralSecurityException("Cannot create key with ID requirement with parameters without ID requirement");
        }
        if (jVar2 == jVar) {
            C0400a.a(new byte[0]);
        } else if (jVar2 == S0.j.f1748o) {
            C0400a.a(ByteBuffer.allocate(5).put((byte) 0).putInt(((Integer) this.f6833d).intValue()).array());
        } else {
            if (jVar2 != S0.j.f1747n) {
                throw new IllegalStateException("Unknown AesGcmParameters.Variant: " + ((q) this.f6831b).e);
            }
            C0400a.a(ByteBuffer.allocate(5).put((byte) 1).putInt(((Integer) this.f6833d).intValue()).array());
        }
        return new p();
    }

    public s t() throws GeneralSecurityException {
        C0690c c0690c;
        S0.t tVar = (S0.t) this.f6831b;
        if (tVar == null || (c0690c = (C0690c) this.f6832c) == null) {
            throw new GeneralSecurityException("Cannot build without parameters and/or key material");
        }
        if (tVar.f1782b != ((C0400a) c0690c.f6642b).f4284a.length) {
            throw new GeneralSecurityException("Key size mismatch");
        }
        S0.j jVar = S0.j.f1752s;
        S0.j jVar2 = tVar.f1783c;
        if (jVar2 != jVar && ((Integer) this.f6833d) == null) {
            throw new GeneralSecurityException("Cannot create key without ID requirement with parameters with ID requirement");
        }
        if (jVar2 == jVar && ((Integer) this.f6833d) != null) {
            throw new GeneralSecurityException("Cannot create key with ID requirement with parameters without ID requirement");
        }
        if (jVar2 == jVar) {
            C0400a.a(new byte[0]);
        } else if (jVar2 == S0.j.f1751r) {
            C0400a.a(ByteBuffer.allocate(5).put((byte) 0).putInt(((Integer) this.f6833d).intValue()).array());
        } else {
            if (jVar2 != S0.j.f1750q) {
                throw new IllegalStateException("Unknown AesGcmSivParameters.Variant: " + ((S0.t) this.f6831b).f1783c);
            }
            C0400a.a(ByteBuffer.allocate(5).put((byte) 1).putInt(((Integer) this.f6833d).intValue()).array());
        }
        return new s();
    }

    public String toString() {
        switch (this.f6830a) {
            case 12:
                return R0.p.a((g0) this.f6831b).toString();
            case 20:
                return ((C0171b) this.f6832c).toString() + ", hidden list:" + ((ArrayList) this.f6833d).size();
            default:
                return super.toString();
        }
    }

    public W0.a u() throws GeneralSecurityException {
        C0690c c0690c;
        W0.c cVar = (W0.c) this.f6831b;
        if (cVar == null || (c0690c = (C0690c) this.f6832c) == null) {
            throw new IllegalArgumentException("Cannot build without parameters and/or key material");
        }
        if (cVar.f2260b != ((C0400a) c0690c.f6642b).f4284a.length) {
            throw new GeneralSecurityException("Key size mismatch");
        }
        W0.b bVar = W0.b.f2258d;
        W0.b bVar2 = cVar.f2261c;
        if (bVar2 != bVar && ((Integer) this.f6833d) == null) {
            throw new GeneralSecurityException("Cannot create key without ID requirement with parameters with ID requirement");
        }
        if (bVar2 == bVar && ((Integer) this.f6833d) != null) {
            throw new GeneralSecurityException("Cannot create key with ID requirement with parameters without ID requirement");
        }
        if (bVar2 == bVar) {
            C0400a.a(new byte[0]);
        } else if (bVar2 == W0.b.f2257c) {
            C0400a.a(ByteBuffer.allocate(5).put((byte) 0).putInt(((Integer) this.f6833d).intValue()).array());
        } else {
            if (bVar2 != W0.b.f2256b) {
                throw new IllegalStateException("Unknown AesSivParameters.Variant: " + ((W0.c) this.f6831b).f2261c);
            }
            C0400a.a(ByteBuffer.allocate(5).put((byte) 1).putInt(((Integer) this.f6833d).intValue()).array());
        }
        return new W0.a();
    }

    public Z0.a v() throws GeneralSecurityException {
        C0690c c0690c;
        C0400a c0400aA;
        Z0.e eVar = (Z0.e) this.f6831b;
        if (eVar == null || (c0690c = (C0690c) this.f6832c) == null) {
            throw new GeneralSecurityException("Cannot build without parameters and/or key material");
        }
        if (eVar.f2570b != ((C0400a) c0690c.f6642b).f4284a.length) {
            throw new GeneralSecurityException("Key size mismatch");
        }
        Z0.d dVar = Z0.d.f2558f;
        Z0.d dVar2 = eVar.f2572d;
        if (dVar2 != dVar && ((Integer) this.f6833d) == null) {
            throw new GeneralSecurityException("Cannot create key without ID requirement with parameters with ID requirement");
        }
        if (dVar2 == dVar && ((Integer) this.f6833d) != null) {
            throw new GeneralSecurityException("Cannot create key with ID requirement with parameters without ID requirement");
        }
        if (dVar2 == dVar) {
            c0400aA = C0400a.a(new byte[0]);
        } else if (dVar2 == Z0.d.e || dVar2 == Z0.d.f2557d) {
            c0400aA = C0400a.a(ByteBuffer.allocate(5).put((byte) 0).putInt(((Integer) this.f6833d).intValue()).array());
        } else {
            if (dVar2 != Z0.d.f2556c) {
                throw new IllegalStateException("Unknown AesCmacParametersParameters.Variant: " + ((Z0.e) this.f6831b).f2572d);
            }
            c0400aA = C0400a.a(ByteBuffer.allocate(5).put((byte) 1).putInt(((Integer) this.f6833d).intValue()).array());
        }
        return new Z0.a((Z0.e) this.f6831b, c0400aA);
    }

    public Z0.e w() throws GeneralSecurityException {
        Integer num = (Integer) this.f6831b;
        if (num == null) {
            throw new GeneralSecurityException("key size not set");
        }
        if (((Integer) this.f6832c) == null) {
            throw new GeneralSecurityException("tag size not set");
        }
        if (((Z0.d) this.f6833d) != null) {
            return new Z0.e(num.intValue(), ((Integer) this.f6832c).intValue(), (Z0.d) this.f6833d);
        }
        throw new GeneralSecurityException("variant not set");
    }

    public Z0.j x() throws GeneralSecurityException {
        C0690c c0690c;
        C0400a c0400aA;
        Z0.k kVar = (Z0.k) this.f6831b;
        if (kVar == null || (c0690c = (C0690c) this.f6832c) == null) {
            throw new GeneralSecurityException("Cannot build without parameters and/or key material");
        }
        if (kVar.f2580b != ((C0400a) c0690c.f6642b).f4284a.length) {
            throw new GeneralSecurityException("Key size mismatch");
        }
        Z0.d dVar = Z0.d.f2567o;
        Z0.d dVar2 = kVar.f2582d;
        if (dVar2 != dVar && ((Integer) this.f6833d) == null) {
            throw new GeneralSecurityException("Cannot create key without ID requirement with parameters with ID requirement");
        }
        if (dVar2 == dVar && ((Integer) this.f6833d) != null) {
            throw new GeneralSecurityException("Cannot create key with ID requirement with parameters without ID requirement");
        }
        if (dVar2 == dVar) {
            c0400aA = C0400a.a(new byte[0]);
        } else if (dVar2 == Z0.d.f2566n || dVar2 == Z0.d.f2565m) {
            c0400aA = C0400a.a(ByteBuffer.allocate(5).put((byte) 0).putInt(((Integer) this.f6833d).intValue()).array());
        } else {
            if (dVar2 != Z0.d.f2564l) {
                throw new IllegalStateException("Unknown HmacParameters.Variant: " + ((Z0.k) this.f6831b).f2582d);
            }
            c0400aA = C0400a.a(ByteBuffer.allocate(5).put((byte) 1).putInt(((Integer) this.f6833d).intValue()).array());
        }
        return new Z0.j((Z0.k) this.f6831b, c0400aA);
    }

    public SharedPreferences y(C0530g c0530g) {
        String str = c0530g.f5682a;
        Context context = (Context) this.f6832c;
        if (str != null) {
            SharedPreferences sharedPreferences = context.getSharedPreferences(str, 0);
            J3.i.b(sharedPreferences);
            return sharedPreferences;
        }
        SharedPreferences sharedPreferences2 = context.getSharedPreferences(context.getPackageName() + "_preferences", 0);
        J3.i.b(sharedPreferences2);
        return sharedPreferences2;
    }

    public void z(int i4, io.flutter.view.h hVar) {
        ((FlutterJNI) this.f6832c).dispatchSemanticsAction(i4, hVar);
    }

    public /* synthetic */ C0747k(Object obj, Object obj2, Object obj3, int i4) {
        this.f6830a = i4;
        this.f6831b = obj;
        this.f6832c = obj2;
        this.f6833d = obj3;
    }

    public C0747k(Context context) {
        GoogleSignInOptions googleSignInOptionsC;
        String strD;
        this.f6830a = 0;
        C0738b c0738bA = C0738b.a(context);
        this.f6831b = c0738bA;
        this.f6832c = c0738bA.b();
        String strD2 = c0738bA.d("defaultGoogleSignInAccount");
        if (TextUtils.isEmpty(strD2) || (strD = c0738bA.d(C0738b.f("googleSignInOptions", strD2))) == null) {
            googleSignInOptionsC = null;
        } else {
            try {
                googleSignInOptionsC = GoogleSignInOptions.c(strD);
            } catch (JSONException unused) {
                googleSignInOptionsC = null;
            }
        }
        this.f6833d = googleSignInOptionsC;
    }

    public C0747k(C0229f c0229f, String str, H0.a aVar) {
        this.f6830a = 24;
        this.f6833d = c0229f;
        this.f6831b = str;
        this.f6832c = aVar;
    }

    /* JADX WARN: 'this' call moved to the top of the method (can break code semantics) */
    public C0747k(O2.f fVar, String str, int i4) {
        this(fVar, str, r.f1458a, 11);
        this.f6830a = i4;
        switch (i4) {
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                break;
            default:
                r rVar = r.f1458a;
                this.f6831b = fVar;
                this.f6832c = str;
                this.f6833d = rVar;
                break;
        }
    }

    public C0747k(C0690c c0690c) {
        this.f6830a = 20;
        this.f6831b = c0690c;
        this.f6832c = new C0171b();
        this.f6833d = new ArrayList();
    }

    public C0747k(int i4) {
        this.f6830a = i4;
        switch (i4) {
            case 5:
                this.f6831b = new int[]{0};
                this.f6832c = new int[]{0};
                this.f6833d = new int[]{0};
                break;
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                this.f6831b = new ConcurrentLinkedQueue();
                break;
            default:
                this.f6831b = new float[]{0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f};
                this.f6832c = new PointF(100.0f, 100.0f);
                this.f6833d = new PointF(0.0f, 0.0f);
                break;
        }
    }

    public C0747k(byte[] bArr) throws GeneralSecurityException {
        this.f6830a = 25;
        e1.q.a(bArr.length);
        SecretKeySpec secretKeySpec = new SecretKeySpec(bArr, "AES");
        this.f6831b = secretKeySpec;
        if (B1.a.f(1)) {
            Cipher cipher = (Cipher) e1.j.f3998b.f4000a.e("AES/ECB/NoPadding");
            cipher.init(1, secretKeySpec);
            byte[] bArrN = AbstractC0184a.n(cipher.doFinal(new byte[16]));
            this.f6832c = bArrN;
            this.f6833d = AbstractC0184a.n(bArrN);
            return;
        }
        throw new GeneralSecurityException("Can not use AES-CMAC in FIPS-mode.");
    }

    public C0747k(F1.a aVar) {
        this.f6830a = 1;
        this.f6832c = new CopyOnWriteArrayList();
        this.f6833d = new HashMap();
        this.f6831b = aVar;
    }

    public C0747k(Context context, TypedArray typedArray) {
        this.f6830a = 27;
        this.f6831b = context;
        this.f6832c = typedArray;
    }

    public C0747k(p1.d dVar) {
        this.f6830a = 19;
        this.f6831b = new H(30);
        this.f6832c = new ArrayList();
        this.f6833d = new ArrayList();
        new p1.d(this, 26);
    }

    public C0747k(F2.b bVar, FlutterJNI flutterJNI) {
        this.f6830a = 7;
        C0690c c0690c = new C0690c(this, 7);
        C0053n c0053n = new C0053n(bVar, "flutter/accessibility", O2.q.f1455a, null, 5);
        this.f6831b = c0053n;
        c0053n.y(c0690c);
        this.f6832c = flutterJNI;
    }

    public C0747k(E e4) {
        this.f6830a = 3;
        this.f6832c = new HashSet();
        this.f6833d = e4;
        D2.r rVar = (D2.r) e4;
        this.f6831b = new D[]{new z(rVar.getBinaryMessenger()), new v(new C0690c(rVar.getBinaryMessenger()))};
        new C0779j(rVar.getBinaryMessenger()).f6969b = this;
    }

    public C0747k(C0747k c0747k, O2.h hVar) {
        this.f6830a = 9;
        this.f6833d = c0747k;
        this.f6832c = new AtomicReference(null);
        this.f6831b = hVar;
    }

    public C0747k(ConcurrentHashMap concurrentHashMap, ArrayList arrayList, R0.l lVar, C0243a c0243a, Class cls) {
        this.f6830a = 13;
        this.f6831b = concurrentHashMap;
        this.f6832c = lVar;
        this.f6833d = c0243a;
    }

    public C0747k(O2.f fVar, Context context, X.N n4) {
        this.f6830a = 29;
        J3.i.e(fVar, "messenger");
        J3.i.e(context, "context");
        this.f6831b = fVar;
        this.f6832c = context;
        this.f6833d = n4;
        try {
            InterfaceC0529f.f5681l.getClass();
            C0528e.b(fVar, this, "shared_preferences");
        } catch (Exception e4) {
            Log.e("SharedPreferencesPlugin", "Received exception while setting up SharedPreferencesBackend", e4);
        }
    }

    public C0747k(B.k kVar) {
        this.f6830a = 28;
        this.f6831b = kVar;
        this.f6832c = new ReentrantLock();
        this.f6833d = new WeakHashMap();
    }

    public C0747k(g0 g0Var, List list) {
        this.f6830a = 12;
        this.f6831b = g0Var;
        this.f6832c = list;
        this.f6833d = C0243a.f3269b;
    }
}
