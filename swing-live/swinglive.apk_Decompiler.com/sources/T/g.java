package t;

import android.content.Context;
import android.content.res.AssetManager;
import android.content.res.Resources;
import android.graphics.Typeface;
import android.graphics.fonts.FontVariationAxis;
import android.net.Uri;
import android.os.ParcelFileDescriptor;
import android.util.Log;
import e1.k;
import java.io.IOException;
import java.lang.reflect.Array;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.nio.ByteBuffer;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import x.C0710g;

/* JADX INFO: loaded from: classes.dex */
public class g extends e {

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final Class f6523h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final Constructor f6524i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final Method f6525j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final Method f6526k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final Method f6527l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final Method f6528m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final Method f6529n;

    public g() {
        Class<?> cls;
        Method method;
        Constructor<?> constructor;
        Method methodJ0;
        Method method2;
        Method method3;
        Method methodK0;
        try {
            cls = Class.forName("android.graphics.FontFamily");
            constructor = cls.getConstructor(new Class[0]);
            methodJ0 = j0(cls);
            Class cls2 = Integer.TYPE;
            method2 = cls.getMethod("addFontFromBuffer", ByteBuffer.class, cls2, FontVariationAxis[].class, cls2, cls2);
            method3 = cls.getMethod("freeze", new Class[0]);
            method = cls.getMethod("abortCreation", new Class[0]);
            methodK0 = k0(cls);
        } catch (ClassNotFoundException | NoSuchMethodException e) {
            Log.e("TypefaceCompatApi26Impl", "Unable to collect necessary methods for class ".concat(e.getClass().getName()), e);
            cls = null;
            method = null;
            constructor = null;
            methodJ0 = null;
            method2 = null;
            method3 = null;
            methodK0 = null;
        }
        this.f6523h = cls;
        this.f6524i = constructor;
        this.f6525j = methodJ0;
        this.f6526k = method2;
        this.f6527l = method3;
        this.f6528m = method;
        this.f6529n = methodK0;
    }

    public static Method j0(Class cls) {
        Class cls2 = Integer.TYPE;
        return cls.getMethod("addFontFromAssetManager", AssetManager.class, String.class, cls2, Boolean.TYPE, cls2, cls2, cls2, FontVariationAxis[].class);
    }

    public final void e0(Object obj) {
        try {
            this.f6528m.invoke(obj, new Object[0]);
        } catch (IllegalAccessException | InvocationTargetException unused) {
        }
    }

    public final boolean f0(Context context, Object obj, String str, int i4, int i5, int i6, FontVariationAxis[] fontVariationAxisArr) {
        try {
            return ((Boolean) this.f6525j.invoke(obj, context.getAssets(), str, 0, Boolean.FALSE, Integer.valueOf(i4), Integer.valueOf(i5), Integer.valueOf(i6), fontVariationAxisArr)).booleanValue();
        } catch (IllegalAccessException | InvocationTargetException unused) {
            return false;
        }
    }

    public Typeface g0(Object obj) {
        try {
            Object objNewInstance = Array.newInstance((Class<?>) this.f6523h, 1);
            Array.set(objNewInstance, 0, obj);
            return (Typeface) this.f6529n.invoke(null, objNewInstance, -1, -1);
        } catch (IllegalAccessException | InvocationTargetException unused) {
            return null;
        }
    }

    public final boolean h0(Object obj) {
        try {
            return ((Boolean) this.f6527l.invoke(obj, new Object[0])).booleanValue();
        } catch (IllegalAccessException | InvocationTargetException unused) {
            return false;
        }
    }

    @Override // t.e, e1.AbstractC0367g
    public final Typeface i(Context context, s.f fVar, Resources resources, int i4) {
        Method method = this.f6525j;
        if (method == null) {
            Log.w("TypefaceCompatApi26Impl", "Unable to collect necessary private methods. Fallback to legacy implementation.");
        }
        if (method == null) {
            return super.i(context, fVar, resources, i4);
        }
        Object objI0 = i0();
        if (objI0 != null) {
            s.g[] gVarArr = fVar.f6443a;
            int length = gVarArr.length;
            int i5 = 0;
            while (i5 < length) {
                s.g gVar = gVarArr[i5];
                String str = gVar.f6444a;
                FontVariationAxis[] fontVariationAxisArrFromFontVariationSettings = FontVariationAxis.fromFontVariationSettings(gVar.f6447d);
                Context context2 = context;
                if (!f0(context2, objI0, str, gVar.e, gVar.f6445b, gVar.f6446c ? 1 : 0, fontVariationAxisArrFromFontVariationSettings)) {
                    e0(objI0);
                    return null;
                }
                i5++;
                context = context2;
            }
            if (h0(objI0)) {
                return g0(objI0);
            }
        }
        return null;
    }

    public final Object i0() {
        try {
            return this.f6524i.newInstance(new Object[0]);
        } catch (IllegalAccessException | InstantiationException | InvocationTargetException unused) {
            return null;
        }
    }

    @Override // t.e, e1.AbstractC0367g
    public final Typeface j(Context context, C0710g[] c0710gArr, int i4) {
        Typeface typefaceG0;
        boolean zBooleanValue;
        if (c0710gArr.length >= 1) {
            Method method = this.f6525j;
            if (method == null) {
                Log.w("TypefaceCompatApi26Impl", "Unable to collect necessary private methods. Fallback to legacy implementation.");
            }
            if (method != null) {
                HashMap map = new HashMap();
                for (C0710g c0710g : c0710gArr) {
                    if (c0710g.e == 0) {
                        Uri uri = c0710g.f6743a;
                        if (!map.containsKey(uri)) {
                            map.put(uri, k.y(context, uri));
                        }
                    }
                }
                Map mapUnmodifiableMap = Collections.unmodifiableMap(map);
                Object objI0 = i0();
                if (objI0 != null) {
                    int length = c0710gArr.length;
                    int i5 = 0;
                    boolean z4 = false;
                    while (i5 < length) {
                        C0710g c0710g2 = c0710gArr[i5];
                        ByteBuffer byteBuffer = (ByteBuffer) mapUnmodifiableMap.get(c0710g2.f6743a);
                        if (byteBuffer != null) {
                            try {
                                zBooleanValue = ((Boolean) this.f6526k.invoke(objI0, byteBuffer, Integer.valueOf(c0710g2.f6744b), null, Integer.valueOf(c0710g2.f6745c), Integer.valueOf(c0710g2.f6746d ? 1 : 0))).booleanValue();
                            } catch (IllegalAccessException | InvocationTargetException unused) {
                                zBooleanValue = false;
                            }
                            if (!zBooleanValue) {
                                e0(objI0);
                                return null;
                            }
                            z4 = true;
                        }
                        i5++;
                        z4 = z4;
                    }
                    if (!z4) {
                        e0(objI0);
                        return null;
                    }
                    if (h0(objI0) && (typefaceG0 = g0(objI0)) != null) {
                        return Typeface.create(typefaceG0, i4);
                    }
                }
            } else {
                C0710g c0710gR = r(c0710gArr, i4);
                try {
                    ParcelFileDescriptor parcelFileDescriptorOpenFileDescriptor = context.getContentResolver().openFileDescriptor(c0710gR.f6743a, "r", null);
                    if (parcelFileDescriptorOpenFileDescriptor != null) {
                        try {
                            Typeface typefaceBuild = new Typeface.Builder(parcelFileDescriptorOpenFileDescriptor.getFileDescriptor()).setWeight(c0710gR.f6745c).setItalic(c0710gR.f6746d).build();
                            parcelFileDescriptorOpenFileDescriptor.close();
                            return typefaceBuild;
                        } finally {
                        }
                    }
                    if (parcelFileDescriptorOpenFileDescriptor != null) {
                        parcelFileDescriptorOpenFileDescriptor.close();
                        return null;
                    }
                } catch (IOException unused2) {
                }
            }
        }
        return null;
    }

    public Method k0(Class cls) throws NoSuchMethodException {
        Class<?> cls2 = Array.newInstance((Class<?>) cls, 1).getClass();
        Class cls3 = Integer.TYPE;
        Method declaredMethod = Typeface.class.getDeclaredMethod("createFromFamiliesWithDefault", cls2, cls3, cls3);
        declaredMethod.setAccessible(true);
        return declaredMethod;
    }

    @Override // e1.AbstractC0367g
    public final Typeface l(Context context, Resources resources, int i4, String str, int i5) {
        Method method = this.f6525j;
        if (method == null) {
            Log.w("TypefaceCompatApi26Impl", "Unable to collect necessary private methods. Fallback to legacy implementation.");
        }
        if (method == null) {
            return super.l(context, resources, i4, str, i5);
        }
        Object objI0 = i0();
        if (objI0 != null) {
            if (!f0(context, objI0, str, 0, -1, -1, null)) {
                e0(objI0);
                return null;
            }
            if (h0(objI0)) {
                return g0(objI0);
            }
        }
        return null;
    }
}
