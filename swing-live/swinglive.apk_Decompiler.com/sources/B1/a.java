package B1;

import J3.i;
import K.j;
import K.k;
import O.N;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.android.gms.internal.p002firebaseauthapi.zzxr;
import com.google.android.recaptcha.internal.zzhh;
import java.nio.ByteBuffer;

/* JADX INFO: loaded from: classes.dex */
public abstract /* synthetic */ class a {
    public static final void a(int i4, View view, ViewGroup viewGroup) {
        i.e(view, "view");
        i.e(viewGroup, "container");
        int iB = j.b(i4);
        if (iB == 0) {
            ViewParent parent = view.getParent();
            ViewGroup viewGroup2 = parent instanceof ViewGroup ? (ViewGroup) parent : null;
            if (viewGroup2 != null) {
                if (N.J(2)) {
                    Log.v("FragmentManager", "SpecialEffectsController: Removing view " + view + " from container " + viewGroup2);
                }
                viewGroup2.removeView(view);
                return;
            }
            return;
        }
        if (iB == 1) {
            if (N.J(2)) {
                Log.v("FragmentManager", "SpecialEffectsController: Setting view " + view + " to VISIBLE");
            }
            ViewParent parent2 = view.getParent();
            if ((parent2 instanceof ViewGroup ? (ViewGroup) parent2 : null) == null) {
                if (N.J(2)) {
                    Log.v("FragmentManager", "SpecialEffectsController: Adding view " + view + " to Container " + viewGroup);
                }
                viewGroup.addView(view);
            }
            view.setVisibility(0);
            return;
        }
        if (iB == 2) {
            if (N.J(2)) {
                Log.v("FragmentManager", "SpecialEffectsController: Setting view " + view + " to GONE");
            }
            view.setVisibility(8);
            return;
        }
        if (iB != 3) {
            return;
        }
        if (N.J(2)) {
            Log.v("FragmentManager", "SpecialEffectsController: Setting view " + view + " to INVISIBLE");
        }
        view.setVisibility(4);
    }

    public static int b(String str) throws NoSuchFieldException {
        String str2;
        for (int i4 : j.c(2)) {
            if (i4 == 1) {
                str2 = "Brightness.light";
            } else {
                if (i4 != 2) {
                    throw null;
                }
                str2 = "Brightness.dark";
            }
            if (str2.equals(str)) {
                return i4;
            }
        }
        throw new NoSuchFieldException(m("No such Brightness: ", str));
    }

    public static int c(String str) throws NoSuchFieldException {
        for (int i4 : j.c(8)) {
            String str2 = null;
            switch (i4) {
                case 1:
                    break;
                case 2:
                    str2 = "HapticFeedbackType.lightImpact";
                    break;
                case 3:
                    str2 = "HapticFeedbackType.mediumImpact";
                    break;
                case 4:
                    str2 = "HapticFeedbackType.heavyImpact";
                    break;
                case 5:
                    str2 = "HapticFeedbackType.selectionClick";
                    break;
                case k.STRING_SET_FIELD_NUMBER /* 6 */:
                    str2 = "HapticFeedbackType.successNotification";
                    break;
                case k.DOUBLE_FIELD_NUMBER /* 7 */:
                    str2 = "HapticFeedbackType.warningNotification";
                    break;
                case k.BYTES_FIELD_NUMBER /* 8 */:
                    str2 = "HapticFeedbackType.errorNotification";
                    break;
                default:
                    throw null;
            }
            if ((str2 == null && str == null) || (str2 != null && str2.equals(str))) {
                return i4;
            }
        }
        throw new NoSuchFieldException(m("No such HapticFeedbackType: ", str));
    }

    public static int d(String str) throws NoSuchFieldException {
        String str2;
        for (int i4 : j.c(3)) {
            if (i4 == 1) {
                str2 = "SystemSoundType.click";
            } else if (i4 == 2) {
                str2 = "SystemSoundType.tick";
            } else {
                if (i4 != 3) {
                    throw null;
                }
                str2 = "SystemSoundType.alert";
            }
            if (str2.equals(str)) {
                return i4;
            }
        }
        throw new NoSuchFieldException(m("No such SoundType: ", str));
    }

    public static final int e(int i4) {
        switch (j.b(i4)) {
            case 0:
                return 2135033992;
            case 1:
                return 19;
            case 2:
                return 21;
            case 3:
                return 20;
            case 4:
                return 39;
            case 5:
                return 2135042184;
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                return 22;
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                return 24;
            case k.BYTES_FIELD_NUMBER /* 8 */:
                return 23;
            case 9:
                return 40;
            case 10:
                return 2135181448;
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                return 29;
            case 12:
                return 2130708361;
            default:
                return -1;
        }
    }

    public static final boolean f(int i4) {
        return !V0.a.a();
    }

    public static final boolean g(int i4) {
        Boolean bool;
        if (V0.a.a()) {
            try {
                bool = (Boolean) Class.forName("org.conscrypt.Conscrypt").getMethod("isBoringSslFIPSBuild", new Class[0]).invoke(null, new Object[0]);
            } catch (Exception unused) {
                V0.a.f2175a.info("Conscrypt is not available or does not support checking for FIPS build.");
                bool = Boolean.FALSE;
            }
            if (!bool.booleanValue()) {
                return false;
            }
        }
        return true;
    }

    public static int h(int i4, int i5, int i6) {
        return (Integer.hashCode(i4) + i5) * i6;
    }

    public static int i(int i4, int i5, int i6, int i7) {
        return ((i4 * i5) / i6) + i7;
    }

    public static zzxr j(Integer num, ByteBuffer byteBuffer) {
        return zzxr.zza(byteBuffer.putInt(num.intValue()).array());
    }

    public static String k(String str, int i4, int i5, String str2) {
        return str + i4 + str2 + i5;
    }

    public static String l(String str, int i4, String str2) {
        return str + i4 + str2;
    }

    public static String m(String str, String str2) {
        return str + str2;
    }

    public static String n(StringBuilder sb, int i4, String str) {
        sb.append(i4);
        sb.append(str);
        return sb.toString();
    }

    public static /* synthetic */ void o(int i4, String str) {
        if (i4 == 0) {
            StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
            String name = i.class.getName();
            int i5 = 0;
            while (!stackTrace[i5].getClassName().equals(name)) {
                i5++;
            }
            while (stackTrace[i5].getClassName().equals(name)) {
                i5++;
            }
            StackTraceElement stackTraceElement = stackTrace[i5];
            NullPointerException nullPointerException = new NullPointerException("Parameter specified as non-null is null: method " + stackTraceElement.getClassName() + "." + stackTraceElement.getMethodName() + ", parameter " + str);
            i.f(nullPointerException, i.class.getName());
            throw nullPointerException;
        }
    }

    public static /* synthetic */ void p(Object obj) {
        if (obj != null) {
            throw new ClassCastException();
        }
    }

    public static int q(int i4, int i5, int i6) {
        return zzhh.zzy(i4) + i5 + i6;
    }

    public static /* synthetic */ String r(int i4) {
        switch (i4) {
            case 1:
                return "YUV420FLEXIBLE";
            case 2:
                return "YUV420PLANAR";
            case 3:
                return "YUV420SEMIPLANAR";
            case 4:
                return "YUV420PACKEDPLANAR";
            case 5:
                return "YUV420PACKEDSEMIPLANAR";
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                return "YUV422FLEXIBLE";
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                return "YUV422PLANAR";
            case k.BYTES_FIELD_NUMBER /* 8 */:
                return "YUV422SEMIPLANAR";
            case 9:
                return "YUV422PACKEDPLANAR";
            case 10:
                return "YUV422PACKEDSEMIPLANAR";
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                return "YUV444FLEXIBLE";
            case 12:
                return "YUV444INTERLEAVED";
            case 13:
                return "SURFACE";
            case 14:
                return "YUV420Dynamical";
            default:
                throw null;
        }
    }
}
